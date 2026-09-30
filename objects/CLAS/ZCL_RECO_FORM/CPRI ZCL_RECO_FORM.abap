  PRIVATE SECTION.

    " Perf fix (kokpit sıralama/sayfalama yavaşlığı) - D_BOZKAYNAK
    " Aynı filtrelerle gelen paging/sort isteklerinde sos()->get_general_data()->
    " modify_cform_data() zincirini ve zreco_gtout DB yazımını tekrarlamamak için
    " son hesaplanan sonucu ve onu üreten filtre imzasını statik olarak saklar.
    CLASS-DATA: gv_cache_hash   TYPE string,
                gv_cache_uname  TYPE syuname,
                gt_cache_output TYPE TABLE OF zreco_ddl_i_reco_form.
