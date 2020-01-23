/// This business process manages the orchestration of sending and retrieving data from the US Census
Class Demo.ToCensusDS Extends EnsLib.REST.Operation
{

Parameter INVOCATION = "Queue";

/// Calls an external API to get the population density for a particular GeoJSON location.
Method GetPopulationDensity(pRequest As Demo.PopulationRequest, Output pResponse As Demo.PopulationResponse) As %Status
{
  try {
      // Prepare and log the call
      // Append the city to the URL configured for adapter
      set tURL= ..Adapter.URL _ "?get=NAME,B00001_001E&for=block%20group:" _ pRequest.BlockGroup _ "&in=state:" _ pRequest.State _
      "&in=county:" _ pRequest.County _ "&in=tract:" _ pRequest.Tract _ "&key=6c59dddebe1002a5d5a9848e404e19e5f1614ce9"
      
      // Execute the call
      $$$TRACE("Executing call")
      set tSC=..Adapter.GetURL(tURL,.tHttpResponse)
      
      // Return the response
      if $$$ISERR(tSC)&&$IsObject(tHttpResponse)&&$IsObject(tHttpResponse.Data)&&tHttpResponse.Data.Size {
         Set tSC=$$$ERROR($$$EnsErrGeneral,$$$StatusDisplayString(tSC)_":"_tHttpResponse.Data.Read())
      }
      quit:$$$ISERR(tSC)
      if $IsObject(tHttpResponse) {
         // Instantiate the response object
         set pResponse = ##class(Demo.PopulationResponse).%New()
         // Convert JSON into a Proxy Object
         set tSC = ..JSONStreamToObject(tHttpResponse.Data, .tProxy)
         if (tSC){                                 
            // Set response properties from the Proxy Object
            set pResponse.Population = tProxy.GetAt(2).GetAt(2)
            
            $$$TRACE("Object created with " _ pResponse.Population)
            
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
	<MapItem MessageType="Demo.PopulationRequest"> 
		<Method>GetPopulationDensity</Method>
	</MapItem>
</MapItems>
}

}
