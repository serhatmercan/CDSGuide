@AccessControl.authorizationCheck: #NOT_REQUIRED
@ClientHandling.algorithm: #SESSION_VARIABLE
@ClientHandling.type: #CLIENT_DEPENDENT
@EndUserText.label: 'Function AMDP'
@ObjectModel.usageType:{
  dataClass: #TRANSACTIONAL,  
  serviceQuality: #A,
  sizeCategory: #L
}

define table function zsm_f_amdp
  with parameters @Environment.systemField  : #CLIENT
                  p_client                  : abap.clnt

returns
{
  Client         : abap.clnt;
  DocNo          : knumv;
  DocItemNo      : kposn;
  DocItemGuid    : guid;
  PriceBeginTime : cpet_firsttimestamp;
  PriceBeginDate : datum;
  PriceEndTime   : cpet_firsttimestamp;
  PriceEndDate   : datum;
  WorkingDay     : int4;
}
implemented by method
  zsm_cl_amdp=>get_data;

---

CLASS ZSM_CL_AMDP DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_amdp_marker_hdb.

    CLASS-METHODS:
      get_data FOR TABLE FUNCTION zsm_f_amdp.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ZSM_CL_AMDP IMPLEMENTATION.

* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZSM_CL_AMDP=>GET_DATA
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_data BY DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY USING zsm_i_amdp.
    RETURN SELECT DISTINCT p_client                                                   as Client,
                           docno                                                      as DocNo,
                           docitemno                                                  as DocItemNo,
                           docitemguid                                                as DocItemGuid,
                           pricebegintime                                             as PriceBeginTime,
                           pricebegindate                                             as PriceBeginDate,
                           priceendtime                                               as PriceEndTime,
                           priceenddate                                               as PriceEndDate,
                           workdays_between( 'PI', PriceBeginDate, PriceEndDate ) + 1 as WorkingDay
                      FROM zsm_i_amdp;
  ENDMETHOD.
ENDCLASS.