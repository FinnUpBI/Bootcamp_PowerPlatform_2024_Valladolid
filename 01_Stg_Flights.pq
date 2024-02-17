// sharepointSharedFolder
"personal/matias-dev_matiasdev_onmicrosoft_com/Documents/Bootcamp_PowerPlatform_2024_Valladolid/" meta [IsParameterQuery = true, IsParameterQueryRequired = true, Type = type text]

// sharepointSite
"https://matiasdev-my.sharepoint.com/" meta [IsParameterQuery = true, IsParameterQueryRequired = true, Type = type text]

// 01_Stg_Airlines
let
  Origen = Csv.Document(Web.Contents
    (
        sharepointSite &
        sharepointSharedFolder &
        "airlines.csv"
    ), 
    [Delimiter = ",", Columns = 2, QuoteStyle = QuoteStyle.None]),
  PromHeaders = Table.PromoteHeaders(Origen, [PromoteAllScalars = true])
in
  PromHeaders

// 01_Stg_Airports
let
  Origen = Csv.Document(Web.Contents
    (
        sharepointSite &
        sharepointSharedFolder &
        "airports.csv"
    ), 
    [Delimiter = ",", Columns = 7, QuoteStyle = QuoteStyle.None]),
  PromHeaders = Table.PromoteHeaders(Origen, [PromoteAllScalars = true])
in
  PromHeaders

// 01_Stg_flights
let
  Origen = Csv.Document(Web.Contents
    (
        sharepointSite &
        sharepointSharedFolder &
        "flights.csv"
    ), 
    [Delimiter = ",", Columns = 31, QuoteStyle = QuoteStyle.None]),
  PromHeaders = Table.PromoteHeaders(Origen, [PromoteAllScalars = true])
in
  PromHeaders