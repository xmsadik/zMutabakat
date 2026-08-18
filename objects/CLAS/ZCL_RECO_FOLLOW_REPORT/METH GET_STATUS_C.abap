  METHOD get_status_c.
    DATA : lv_url       TYPE string,
           lv_username  TYPE string,
           lv_password  TYPE string,
           lv_sjson     TYPE string,
*           lv_json      TYPE xstring,
           lv_xresponse TYPE xstring,
           lv_response  TYPE string,
           lv_http_code TYPE i,
           lv_status    TYPE string,
*           lo_http_client TYPE REF TO if_web_http_client,                                                        "D_MBAYEL
           ls_input_rtn TYPE zreco_mtb_return,
           lr_oref      TYPE REF TO cx_root,
           ls_response  TYPE zreco_mtb_return_itm_c.
    CONSTANTS    lc_success_code TYPE i VALUE 200.
    DATA lv_recousername TYPE string.

    DATA ls_srvc TYPE zreco_srvc.

    DATA: zreco_cl_json TYPE REF TO zreco_common.
    CREATE OBJECT zreco_cl_json.

    SELECT SINGLE *
          FROM zreco_adrs
         WHERE bukrs EQ @ls_h001-bukrs
        INTO @DATA(ls_adrs).

    SELECT SINGLE *
      FROM zreco_srvc
      WHERE srvid EQ '003'
        AND bukrs EQ @ls_h001-bukrs OR bukrs EQ @space
        INTO @ls_srvc.

    lv_url      = ls_srvc-srvurl.
    lv_username = ls_srvc-srvusr.
    lv_password = ls_srvc-srvpsw.



    SELECT SINGLE username
    FROM zreco_t_re
    WHERE reconciliationnumber EQ @ls_h001-mnumber
    INTO @lv_recousername.


    IF ls_h001-land1 IS NOT INITIAL.
      IF ls_h001-land1 EQ 'TR'  .
        ls_input_rtn-cultureinfo = 'tr-TR'.
      ELSE.
        ls_input_rtn-cultureinfo = 'en-US'.
      ENDIF.
    ENDIF.

    IF lv_recousername IS NOT INITIAL.
      ls_input_rtn-reconciliationuniqnumber = lv_recousername.
    ENDIF.

    TRY .
      CATCH cx_root INTO lr_oref .
    ENDTRY.



    DATA(lv_json) =  /ui2/cl_json=>serialize( EXPORTING data = ls_input_rtn pretty_name = 'X' ).
    DATA(lv_comp) = ls_adrs-adres.

    TRY.
        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( CONV #( ls_srvc-srvurl ) ).
        DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .
        DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
        lo_web_http_request->set_authorization_basic(
          EXPORTING
            i_username = CONV #( ls_srvc-srvusr )
            i_password = CONV #( ls_srvc-srvpsw )
        ).

        lo_web_http_request->set_header_fields( VALUE #( (  name = 'Accept' value = 'application/json' )
                                                         (  name = 'Content-Type' value = 'application/json' )
                                                         (  name = 'CompanyName' value = |{ lv_comp }| )
                                                          ) ).
        lo_web_http_request->set_text(
          EXPORTING
            i_text   = lv_json
        ).

        DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>post ).
        lv_response = lo_web_http_response->get_text( ).


        lo_web_http_response->get_status(
          RECEIVING
            r_value = DATA(ls_status)
        ).
        IF ls_status-code = lc_success_code. "success
          .
        ELSE.
        ENDIF.

*!
        /ui2/cl_json=>deserialize(
          EXPORTING
            json = lv_response
          CHANGING
            data = ls_response
        ).



        ls_answer_c = ls_response.



      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
    ENDTRY.

  ENDMETHOD.