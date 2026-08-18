  METHOD if_apj_dt_exec_object~get_parameters.

*    et_parameter_def = VALUE #( ( selname = 'S_ERDAT'
*                                  kind = if_apj_dt_exec_object=>select_option
*                                  datatype = 'D'
*                                  length = 8
*                                  param_text = 'Yaratma Tarihi'
*                                  changeable_ind = abap_true )
*                                ( selname = 'P_SELD'
*                                  kind = if_apj_dt_exec_object=>parameter
*                                  datatype = 'C'
*                                  length = 1
*                                  param_text = 'Müşterileri Seç'
*                                  changeable_ind = abap_true )
*                                ( selname = 'S_KUNNR'
*                                  kind = if_apj_dt_exec_object=>select_option
*                                  datatype = 'C'
*                                  length = 10
*                                  param_text = 'Müşteri No'
*                                  changeable_ind = abap_true )
*                                ( selname = 'P_SELK'
*                                  kind = if_apj_dt_exec_object=>parameter
*                                  datatype = 'C'
*                                  length = 1
*                                  param_text = 'Satıcıları Seç'
*                                  changeable_ind = abap_true )
*                                ( selname = 'S_LIFNR'
*                                  kind = if_apj_dt_exec_object=>select_option
*                                  datatype = 'C'
*                                  length = 10
*                                  param_text = 'Satıcı No'
*                                  changeable_ind = abap_true )
*                                ( selname = 'P_BLK'
*                                  kind = if_apj_dt_exec_object=>parameter
*                                  datatype = 'C'
*                                  length = 1
*                                  param_text = 'Blokajlıları Hariç Tut'
*                                  changeable_ind = abap_true )
*                                ( selname = 'P_DEL'
*                                  kind = if_apj_dt_exec_object=>parameter
*                                  datatype = 'C'
*                                  length = 1
*                                  param_text = 'Simge Göstergeliler Hariç Tut'
*                                  changeable_ind = abap_true )
*                                  ).

  ENDMETHOD.