CLASS zreco_cl_ads_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      ty_cscn_id          TYPE c LENGTH 30,
      ty_cscn_outb_srv_id TYPE c LENGTH 40,
      ty_cs_id            TYPE c LENGTH 60,
      ty_qname            TYPE c LENGTH 32,
      ty_docname          TYPE c LENGTH 120,
      BEGIN OF ty_queue_name,
        qname        TYPE c LENGTH 32,
        qdescription TYPE c LENGTH 80,
      END OF ty_queue_name,
      tyt_queue_name TYPE TABLE OF ty_queue_name.

    CLASS-METHODS: call_adobe IMPORTING iv_form_name            TYPE string
                                        iv_template_name        TYPE string
                                        iv_xml                  TYPE string
                                        iv_adobe_scenario       TYPE ty_cscn_id
                                        iv_adobe_system         TYPE ty_cs_id
                                        iv_adobe_service_id     TYPE ty_cscn_outb_srv_id
                                        iv_queue_name           TYPE ty_qname OPTIONAL
                                        iv_print_ser_scenario   TYPE ty_cscn_id OPTIONAL
                                        iv_print_ser_system     TYPE ty_cs_id OPTIONAL
                                        iv_print_ser_service_id TYPE ty_cscn_outb_srv_id OPTIONAL
                              EXPORTING ev_pdf                  TYPE string
                                        ev_response_code        TYPE int4
                                        ev_response_text        TYPE string
                              RAISING
                                        cx_http_dest_provider_error,

      send_queue IMPORTING iv_queue_name       TYPE ty_qname
                           iv_pdf              TYPE string
                           iv_document_name    TYPE string OPTIONAL
                           iv_number_of_copies TYPE cl_print_queue_utils=>ty_nr_copies DEFAULT 1
                           iv_pages            TYPE cl_print_queue_utils=>ty_page_count DEFAULT 0
*                           iv_print_ser_scenario   TYPE ty_cscn_id
*                           iv_print_ser_system     TYPE ty_cs_id
*                           iv_print_ser_service_id TYPE ty_cscn_outb_srv_id
                 EXPORTING ev_response_code    TYPE int4
                           ev_response_text    TYPE string,

      get_queue_names EXPORTING et_queue_names TYPE tyt_queue_name
                      RAISING   cx_web_http_client_error
                                cx_http_dest_provider_error
                                /iwbep/cx_cp_remote
                                /iwbep/cx_gateway.

    TYPES:BEGIN OF ty_printcontents,
            object_key    TYPE string,
            document_name TYPE string,
          END OF ty_printcontents.

    TYPES: BEGIN OF ty_printtasks,
             number_of_copies TYPE int4,
             username         TYPE string,
             qname            TYPE string,
             print_contents   TYPE STANDARD TABLE OF ty_printcontents WITH EMPTY KEY,
           END OF ty_printtasks.
