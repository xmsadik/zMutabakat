  METHOD send_queue.
    DATA: ls_printtask  TYPE ty_printtasks,
          lv_print_data TYPE xstring,
          lv_err_msg    TYPE string.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    CONVERT TIME STAMP lv_timestamp TIME ZONE 'TURKEY'
            INTO DATE DATA(lv_date) TIME DATA(lv_time).

    lv_print_data = cl_web_http_utility=>decode_x_base64( encoded = iv_pdf ).
    DATA(lv_qitem_id) = cl_print_queue_utils=>create_queue_itemid( ).

    cl_print_queue_utils=>create_queue_item_by_data(
      EXPORTING
        iv_qname            = iv_queue_name
        iv_print_data       = lv_print_data
        iv_name_of_main_doc = COND #( WHEN iv_document_name IS NOT INITIAL
                                      THEN |{ iv_document_name }_{ lv_date+6(2) }-{ lv_date+4(2) }-{ lv_date(4) }_{ lv_time(2) }{ lv_time+2(2) }{ lv_time+4(2) }|
                                      ELSE |{ iv_queue_name }_{ lv_date+6(2) }-{ lv_date+4(2) }-{ lv_date(4) }_{ lv_time(2) }{ lv_time+2(2) }{ lv_time+4(2) }| )
        iv_itemid           = lv_qitem_id
        iv_pages            = iv_pages
        iv_number_of_copies = iv_number_of_copies
      IMPORTING
        ev_err_msg          = lv_err_msg
    ).

    IF lv_err_msg IS INITIAL.
      ev_response_code = 200.
      ev_response_text = 'Çıktı başarılı bir şekilde yazıcıya aktarıldı.'.
    ELSE.
      ev_response_code = 400.
      ev_response_text = lv_err_msg.
    ENDIF.

  ENDMETHOD.