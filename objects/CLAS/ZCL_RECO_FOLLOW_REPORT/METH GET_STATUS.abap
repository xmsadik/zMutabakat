  METHOD get_status.

    DATA : lv_url         TYPE string,
           lv_username    TYPE string,
           lv_password    TYPE string,
           lv_sjson       TYPE string,
           lv_json        TYPE xstring,
           lv_xresponse   TYPE xstring,
           lv_response    TYPE string,
           lv_http_code   TYPE i,
           lv_status      TYPE string,
           lo_http_client TYPE REF TO if_web_http_client,
           ls_input_rtn   TYPE zreco_mtb_return,
           lr_oref        TYPE REF TO cx_root,
           ls_response    TYPE zreco_mtb_return_itm_b.

    DATA ls_srvc TYPE zreco_srvc.
    DATA: zreco_cl_json TYPE REF TO zreco_common.
    CREATE OBJECT zreco_cl_json.

    SELECT SINGLE *
    FROM zreco_srvc
    WHERE srvid EQ '003'
      AND bukrs EQ @ls_h001-bukrs
       OR bukrs EQ @space
      INTO @ls_srvc .

    lv_url = ls_srvc-srvurl.
    lv_username = ls_srvc-srvusr.
    lv_password = ls_srvc-srvpsw.

    FREE : lo_http_client.

    zreco_cl_json->zreco_data_json(
    IMPORTING
    ev_data = ls_input_rtn
    ).

    lv_sjson = ls_input_rtn-reconciliationuniqnumber.




  ENDMETHOD.