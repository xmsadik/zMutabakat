  METHOD get_queue_names.

*    DATA:
**      lt_business_data TYPE TABLE OF zads_cm_print_queue=>tys_print_queue_info,
*      lo_http_client   TYPE REF TO if_web_http_client,
*      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
*      lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
*      lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.
*
*    TRY.
*        " Create http client
*        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
*                                                     comm_scenario  = 'ZADS_CS_PRINT_QUEUE'
*                                                     comm_system_id = 'ZSNC_CSYS_GENERAL'
*                                                     service_id     = 'ZADS_OS_PRINT_QUEUE_REST' ).
*
*        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
*        lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
*          EXPORTING
*             is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
*                                                 proxy_model_id      = 'ZADS_CM_PRINT_QUEUE'
*                                                 proxy_model_version = '0001' )
*            io_http_client             = lo_http_client
*            iv_relative_service_root   = '/sap/opu/odata/sap/API_CLOUD_PRINT_PULL_SRV' ).
*
*        ASSERT lo_http_client IS BOUND.


*        DATA(lo_function_resource) = lo_client_proxy->create_resource_for_function( zads_cm_print_queue=>gcs_function_import-get_print_queues_of_user ).

*        DATA(lo_function_request) = lo_function_resource->create_request( ).

*        DATA(lo_function_response) = lo_function_request->execute( /iwbep/if_cp_request_function=>gcs_http_method-get ).
*
*        lo_function_response->get_business_data( IMPORTING ea_response_data =  lt_business_data ).
*
*        et_queue_names = CORRESPONDING #( lt_business_data ).
*
*      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
*
*      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
*
*      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
*
*      CATCH cx_http_dest_provider_error.
*
*    ENDTRY.

  ENDMETHOD.