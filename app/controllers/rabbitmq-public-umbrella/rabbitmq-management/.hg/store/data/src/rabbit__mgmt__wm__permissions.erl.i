        �  w       V��������Gj�8I>�<��	��S���            x��TMo�F��W ��sT����F��ʪC�%9"']KɎ���YR���Ar�avߛyofxv �
!�ʡr�
\EV$�A�m�	sN��LR
�����)Geqp��X�
��s����z�Ϻ�Z<��Z�GY�)����%�u#I�aC���xbxܱ��	R �u��}x��L�s�8I6�M\�e�ڔ���:���{�r�� �e��ZU�9��Z��H�`8����aO�	K6��W�?������l6��?���0�}�?�n/#@�����l��b����';'�iW�/�6�ӊ��B��(J�F�H�`���qB �&'���<���}��KJH��E�q&����_p#g�y$�NY-�B^)r��K\��7~߄SN�lO
s�+��.	-\����{ة��"������3�f��Z4k<!T}��	l8���N�պh%�+ ��ڥ�:e�5Y?�6��wP,�}H�#ގ���*y�W)u�ڴ1zM��l*ZWiC�}`�1��e[`*)��j�W�0�œ�P\9d�)dW(oM����>�G����p/7H���!�~���'�l�/��m����ND]o��y�[�]l���Ȼ�M��Ã�/��F�$����e���?��׎WR8..8���C����(ڝ)|��^�缰�g�{�t]i�=���!\~���346�a�!�ǣ��Z�1����P�b{�5zͷxz\�4��z]�A˗}�7]>���{}��u$�?�Ń� ��    �     X  �       c    �����~i6� w���n`[�W���              �  �   -include("rabbit_mgmt.hrl").
  0  R   #init(_Config) -> {ok, #context{}}.
    M     m  v       s   ����E �ϙ@��g|�G��O�DO�            x�c``]���f����� E�II�%��%�%�9VE�9�\
`�,��_��XbU�Z��Y\���W���PS��`�� .�ՁjJ-tI,I�Qp��+I�(��� �%    �     |  z       �   ����7t��ٸm���JN2U%�߾            x�c``��������a���+�*�d�[��$����ip)�����0��Z��40P��U(JLJ�,�OLNN-.�O��+)�ϱ_��$�6eg��k�i�b7+���54c5u� �I:.    6     L  �       �   �����0� E��\pT���ۣ���              �  �   @    %% TODO call rabbit_access_control:list_permissions instead
    �     H  �       �   ����
������u\�yd �̕���              �  �   <    rabbit_mgmt_util:is_authorized_admin(ReqData, Context).
    �     B  �       �   ����Z��!1��`��\UE�I�              �  �   6    Perms = rabbit_access_control:list_permissions(),
         �  T       �   �����(�����e�@�!x.��-��            x�c``nd c�Ԋ�����Ԣ�b}�XM=.���Ӂ��
@P����Y���[_Z��cU�Z�S�֡����Z�X������W�ZQ6��;3l�RUե��Z��k�rV4����rK�@J2��3��54��@��F!@�F��������d�s��s�r2�K�uj��q ��O�    �     `  T       �   ����C�	���l�-6�t�4ۭ{F            x�c``��������� �E�II�%��%�i�E��%V�E���ř�y��
55\
P�`�� Ց���Z\���WR��c��Y\��S3V� �#M          v  f       �   �������y�e>]��.�A[���            x�c``nd``���� ��ZQ�_T�]�Z��Y\���W�o��������v@U�
@P����Y���[_Z��cU�Z�S���OCSG!(��%�$QG�9?�$��b�s �4HE��� vO'�    �     ]  z         	����� ' �򥌽�ݴ�?&��Ŷ                J   Q    rabbit_mgmt_util:reply_list(permissions(), [vhost, user], ReqData, Context).
    �     j  �         
����r�t�ڇ�r�)���c���            x�c``�e``�c``(U ��Ĥ�̒���ܒ�Ғ���Ԃ��������Ԣ�������bM�h�����%����"�X. (��%�$QG�9?�$��DS� �:!�    ]     �  ;      �   �����L����{o́�%}�y��J            x�m̽
�0��n��o)(�;�,uq(� �i{l1-i��y�Ά����/��M4��h� �5coU���H���:�d�+��I#+��q8�Gq�kA4����{��l�gݴl�\���/�CZ^�����O���U�0+�H�XG�X�	l�Ơ:X���\���;v    �     K  B      /   ����-����;�լ�'v�                ;   ?        P <- rabbit_auth_backend_internal:list_permissions()].
