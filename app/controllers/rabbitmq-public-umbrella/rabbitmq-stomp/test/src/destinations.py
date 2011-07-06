import unittest
import stomp
import base
import time

class TestExchange(base.BaseTest):


    def test_amq_direct(self):
        ''' Test basic send/receive for /exchange/amq.direct '''
        self.__test_exchange_send_rec("amq.direct", "route")

    def test_amq_topic(self):
        ''' Test basic send/receive for /exchange/amq.topic '''
        self.__test_exchange_send_rec("amq.topic", "route")

    def test_amq_fanout(self):
        ''' Test basic send/receive for /exchange/amq.fanout '''
        self.__test_exchange_send_rec("amq.fanout", "route")

    def test_amq_fanout_no_route(self):
        ''' Test basic send/receive for /exchange/amq.direct with no
        routing key'''
        self.__test_exchange_send_rec("amq.fanout")

    def test_invalid_exchange(self):
        ''' Test invalid exchange error '''
        self.listener.reset()
        self.conn.subscribe(destination="/exchange/does.not.exist")
        self.listener.await()
        self.assertEquals(1, len(self.listener.errors))
        err = self.listener.errors[0]
        self.assertEquals("not_found", err['headers']['message'])
        self.assertEquals(
            "NOT_FOUND - no exchange 'does.not.exist' in vhost '/'\n",
            err['message'])
        time.sleep(1)
        self.assertFalse(self.conn.is_connected())

    def __test_exchange_send_rec(self, exchange, route = None):
        dest = "/exchange/" + exchange
        if route != None:
            dest += "/" + route

        self.simple_test_send_rec(dest)

class TestQueue(base.BaseTest):

    def test_send_receive(self):
        ''' Test basic send/receive for /queue '''
        d = '/queue/test'
        self.simple_test_send_rec(d)

    def test_send_receive_in_other_conn(self):
        ''' Test send in one connection, receive in another '''
        d = '/queue/test2'

        # send
        self.conn.send("hello", destination=d)

        # now receive
        conn2 = self.create_connection()
        try:
            listener2 = base.WaitableListener()
            conn2.set_listener('', listener2)

            conn2.subscribe(destination=d)
            self.assertTrue(listener2.await(10), "no receive")
        finally:
            conn2.stop()

    def test_send_receive_in_other_conn_with_disconnect(self):
        ''' Test send, disconnect, receive '''
        d = '/queue/test3'

        # send
        self.conn.send("hello thar", destination=d, receipt="foo")
        self.listener.await(3)
        self.conn.stop()

        # now receive
        conn2 = self.create_connection()
        try:
            listener2 = base.WaitableListener()
            conn2.set_listener('', listener2)

            conn2.subscribe(destination=d)
            self.assertTrue(listener2.await(10), "no receive")
        finally:
            conn2.stop()


    def test_multi_subscribers(self):
        ''' Test multiple subscribers against a single /queue destination '''
        d = '/queue/test-multi'

        ## set up two subscribers
        conn1, listener1 = self.create_subscriber_connection(d)
        conn2, listener2 = self.create_subscriber_connection(d)

        try:
            ## now send
            self.conn.send("test1", destination=d)
            self.conn.send("test2", destination=d)

            ## expect both consumers to get a message?
            self.assertTrue(listener1.await(2))
            self.assertEquals(1, len(listener1.messages),
                              "unexpected message count")
            self.assertTrue(listener2.await(2))
            self.assertEquals(1, len(listener2.messages),
                              "unexpected message count")
        finally:
            conn1.stop()
            conn2.stop()

    def test_send_with_receipt(self):
        d = '/queue/test-receipt'
        def noop(): pass
        self.__test_send_receipt(d, noop, noop)

    def test_send_with_receipt_tx(self):
        d = '/queue/test-receipt-tx'
        tx = 'receipt.tx'

        def before():
            self.conn.begin(transaction=tx)

        def after():
            self.assertFalse(self.listener.await(1))
            self.conn.commit(transaction=tx)

        self.__test_send_receipt(d, before, after, {'transaction': tx})

    def test_interleaved_receipt_no_receipt(self):
        ''' Test interleaved receipt/no receipt where the no receipt
            is bracketed by receipts '''

        d = '/queue/ir'

        self.listener.reset(5)

        self.conn.subscribe(destination=d)
        self.conn.send('first', destination=d, receipt='a')
        self.conn.send('second', destination=d)
        self.conn.send('third', destination=d, receipt='b')

        self.assertTrue(self.listener.await(3))

        self.assertEquals(set(['a','b']), self.__gather_receipts())
        self.assertEquals(3, len(self.listener.messages))

    def test_interleaved_receipt_no_receipt_tx(self):
        ''' Test interleaved receipt/no receipt where the no receipt
            is bracketed by receipts with transactions'''

        d = '/queue/ir'
        tx = 'tx.ir'

        prime_count = 100

        # one receipt and message per prime send.
        # then three messages and two receipts
        self.listener.reset((prime_count * 2) + 5)

        self.conn.subscribe(destination=d)
        self.conn.begin(transaction=tx)

        expected = set(['a', 'b'])

        # make this a large transaction to trigger multi-confirm
        for i in range(1, prime_count + 1):
            expected.add(str(i))
            self.conn.send('prime', destination=d, receipt=str(i),
                           transaction=tx)

        self.conn.send('first', destination=d, receipt='a', transaction=tx)
        self.conn.send('second', destination=d, transaction=tx)
        self.conn.send('third', destination=d, receipt='b', transaction=tx)
        self.conn.commit(transaction=tx)

        self.assertTrue(self.listener.await(10))

        missing = expected.difference(self.__gather_receipts())

        self.assertEquals(set(), missing, "Missing receipts: " + str(missing))
        self.assertEquals(prime_count + 3, len(self.listener.messages))

    def test_interleaved_receipt_no_receipt_inverse(self):
        ''' Test interleaved receipt/no receipt where the receipt
            is bracketed by no receipts '''

        d = '/queue/ir'

        self.listener.reset(4)

        self.conn.subscribe(destination=d)
        self.conn.send('first', destination=d)
        self.conn.send('second', destination=d, receipt='a')
        self.conn.send('third', destination=d)

        self.assertTrue(self.listener.await(3))

        self.assertEquals(set(['a']), self.__gather_receipts())
        self.assertEquals(3, len(self.listener.messages))

    def __test_send_receipt(self, destination, before, after, headers = {}):
        count = 50
        self.listener.reset(count)

        before()
        expected_receipts = set()

        for x in range(0, count):
            receipt = "test" + str(x)
            expected_receipts.add(receipt)
            self.conn.send("test receipt", destination=destination,
                           receipt=receipt, headers=headers)
        after()

        self.assertTrue(self.listener.await(5))

        missing_receipts = expected_receipts.difference(
                    self.__gather_receipts())

        self.assertEquals(set(), missing_receipts,
                          "missing receipts: " + str(missing_receipts))

    def __gather_receipts(self):
        result = set()
        for r in self.listener.receipts:
            result.add(r['headers']['receipt-id'])
        return result

class TestTopic(base.BaseTest):

      def test_send_receive(self):
        ''' Test basic send/receive for /topic '''
        d = '/topic/test'
        self.simple_test_send_rec(d)

      def test_send_multiple(self):
          ''' Test /topic with multiple consumers '''
          d = '/topic/multiple'

          ## set up two subscribers
          conn1, listener1 = self.create_subscriber_connection(d)
          conn2, listener2 = self.create_subscriber_connection(d)

          try:
              ## listeners are expecting 2 messages
              listener1.reset(2)
              listener2.reset(2)

              ## now send
              self.conn.send("test1", destination=d)
              self.conn.send("test2", destination=d)

              ## expect both consumers to get both messages
              self.assertTrue(listener1.await(5))
              self.assertEquals(2, len(listener1.messages),
                                "unexpected message count")
              self.assertTrue(listener2.await(5))
              self.assertEquals(2, len(listener2.messages),
                                "unexpected message count")
          finally:
              conn1.stop()
              conn2.stop()

