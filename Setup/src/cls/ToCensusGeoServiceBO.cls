/// This business operation manages sending and receiving GeoJSON data from an API, which is needed in other US Census queries
Class Demo.ToCensusGeoServiceBO Extends EnsLib.REST.Operation
{

Parameter INVOCATION = "Queue";

/// Retrieves GeoJSON data from the USCensus using longitude and latitude.
Method GetGeoInfo(pRequest As Demo.GeoRequest, Output pResponse As Demo.GeoResponse) As %Status
{
  try {
      // Prepare and log the call
      // Append the city to the URL configured for adapter
      set tURL= ..Adapter.URL _ "query?geometry=" _ pRequest.Longitude _ "," _ pRequest.Latitude _ "&geometryType=esriGeometryPoint&outfields=*&returnGeometry=true&returnIdsOnly=false&inSR=4326&f=geojson" //..Adapter.URL_"?q="_pRequest.City
      
      // Execute the call
      $$$TRACE("Executing call")
      set tSC=..Adapter.GetURL(tURL,.tHttpResponse)
      
      // Return the response
      if $$$ISERR(tSC)&&$IsObject(tHttpResponse)&&$IsObject(tHttpResponse.Data)&&tHttpResponse.Data.Size {
         set tSC=$$$ERROR($$$EnsErrGeneral,$$$StatusDisplayString(tSC)_":"_tHttpResponse.Data.Read())
      }
      quit:$$$ISERR(tSC)
      if $IsObject(tHttpResponse) {
         // Instantiate the response object
         set pResponse = ##class(Demo.GeoResponse).%New()
         // Convert JSON into a Proxy Object
         set tSC = ..JSONStreamToObject(tHttpResponse.Data, .tProxy)
         if (tSC){                                 
            // Set response properties from the Proxy Object
            set pResponse.State = tProxy.features.GetAt(1).properties.STATE
            set pResponse.County = tProxy.features.GetAt(1).properties.COUNTY
            set pResponse.Tract = tProxy.features.GetAt(1).properties.TRACT
            set pResponse.BlockGroup = tProxy.features.GetAt(1).properties.BLKGRP
            
            $$$TRACE("Object created with " _ pResponse.State)
            
           } 
       }
   }catch{
       set tSC=$$$SystemError
   }
   quit tSC
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Demo.GeoRequest"> 
		<Method>GetGeoInfo</Method>
	</MapItem>
</MapItems>
}

}
