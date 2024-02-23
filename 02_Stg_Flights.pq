// dataflowId
"11ce5263-9f6f-4696-be1b-d732a43dbcc7" meta [IsParameterQuery = true, IsParameterQueryRequired = true, Type = type text]

// environmentId
"a030154f-85ea-4de7-94b2-4720085602f3" meta [IsParameterQuery = true, IsParameterQueryRequired = true, Type = type text]

// 01_Stg_Airlines
let
  Source        = PowerPlatform.Dataflows([]),
  SourceType    = Source{[Id = "Environments"]}[Data],
  Environment   = SourceType{[groupId = environmentId]}[Data],
  Dataflow      = Environment{[dataflowId = dataflowId]}[Data],
  Entity        = Dataflow{[entity = "01_Stg_Airlines"]}[Data]
in
  Entity

// 01_Stg_Airports
let
  Source        = PowerPlatform.Dataflows([]),
  SourceType    = Source{[Id = "Environments"]}[Data],
  Environment   = SourceType{[groupId = environmentId]}[Data],
  Dataflow      = Environment{[dataflowId = dataflowId]}[Data],
  Entity        = Dataflow{[entity = "01_Stg_Airports"]}[Data]
in
  Entity

// 01_Stg_flights
let
  Source        = PowerPlatform.Dataflows([]),
  SourceType    = Source{[Id = "Environments"]}[Data],
  Environment   = SourceType{[groupId = environmentId]}[Data],
  Dataflow      = Environment{[dataflowId = dataflowId]}[Data],
  Entity        = Dataflow{[entity = "01_Stg_flights"]}[Data]
in
  Entity

// 02_Stg_Airlines
let
  Source = #"01_Stg_Airlines",
  ChName = Table.RenameColumns(Source, {{"IATA_CODE", "ID_AIRLINE"}})
in
  ChName

// 02_Stg_Airports
let
  Source = #"01_Stg_Airports",
  ChName = Table.RenameColumns(Source, {{"IATA_CODE", "ID_CODE"}})
in
  ChName

// 02_Stg_flights
let
  Source = #"01_Stg_flights", 
  ChName = Table.RenameColumns(
    Source, 
    {
      {"AIRLINE", "ID_AIRLINE"}, 
      {"ORIGIN_AIRPORT", "ID_ORIGIN_AIRPORT"}, 
      {"DESTINATION_AIRPORT", "ID_DESTINATION_AIRPORT"}
    }
  ), 
  MgCol_DATE = Table.CombineColumns(
    ChName, 
    {"YEAR", "MONTH", "DAY"}, 
    Combiner.CombineTextByDelimiter("/", QuoteStyle.None), 
    "DATE"
  ), 
  ChType = Table.TransformColumnTypes(MgCol_DATE, {{"DATE", type date}, {"DISTANCE", Int64.Type}, {"ARRIVAL_DELAY", Int64.Type}, {"AIR_TIME", Int64.Type}, {"ELAPSED_TIME", Int64.Type}, {"DEPARTURE_DELAY", Int64.Type}, {"CANCELLED", Int64.Type}})
in
  ChType

// 02_Stg_Calendario
let
    // Autor: Antonio Jurado
    FechaInicial    = #date(2015, 1, 1),
    FechaFinal      = #date(2015, 12, 31),
    vHoy            = Date.From(DateTime.LocalNow()),
    NumDias         = Duration.Days ( FechaFinal - FechaInicial) + 1,
    //Calculamos los días entre las fechas de inicio  fin. Se suma 1 para que al realizar la resta tenga en cuenta el día de inicio.
    Fechas          = List.Dates ( FechaInicial, NumDias, #duration(1,0,0,0)),
    //Creamos una lista de valores que comenzará en la fecha inicial y continuará hasta el número de días indicado en la variable NumDias. La lista se genera en saltos de 1 día, 0 horas, 0 minutos y 0 segundos tal como se define en la función #duration
    #"Convertida en tabla" = Table.FromList ( Fechas, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Convertida en tabla", {{"Column1", type date}}),
    #"Columnas con nombre cambiado" = Table.RenameColumns(#"Tipo cambiado",{{"Column1", "Fecha"}}),
    FechaCompleta = Table.AddColumn(#"Columnas con nombre cambiado", "FechaCompleta", each Date.ToText([Fecha], "dddd, dd ""de"" MMMM ""de"" yyyy"), type text),
    #"Año insertado" = Table.AddColumn(FechaCompleta, "Año", each Date.Year([Fecha]), Int64.Type),
    #"Mes insertado" = Table.AddColumn(#"Año insertado", "Mes", each Date.Month([Fecha]), Int64.Type),
    nombreMes = Table.AddColumn(#"Mes insertado", "nombreMes", each Date.MonthName([Fecha]), type text),
    MesCorto = Table.AddColumn(nombreMes, "MesCorto", each Text.Start( [nombreMes], 3), type text),
    Día = Table.AddColumn(MesCorto, "Día", each Date.Day([Fecha]), Int64.Type),
    DíaSemana = Table.AddColumn(Día, "DíaSemana", each Date.DayOfWeek([Fecha])+1, Int64.Type),
    NombreDíaSemana = Table.AddColumn(DíaSemana, "NombreDía", each Date.DayOfWeekName([Fecha]), type text),
    #"Año Mes" = Table.AddColumn(NombreDíaSemana, "Año Mes", each //Convertimos en Texto la columna del nº de año
Number.ToText ( [Año] )
// Concatenamos un espacio en blanco como separador
& " " &
// Se concatena después las 3 primeras letras del mes de la fecha en idioma ES-ES
Text.Start( Date.MonthName([Fecha], "ES-ES"), 3), type text),
    OrdenAñoMes = Table.AddColumn(#"Año Mes", "ordenAñoMes", each [Año]*100+[Mes], Int64.Type),
    Trimestre = Table.AddColumn(OrdenAñoMes, "Trimestre", each "Trim " & Number.ToText(Date.QuarterOfYear([Fecha])), type text),
    AñoTrimestre = Table.AddColumn(Trimestre, "AñoTrimestre", each Number.ToText([Año]) & "-" & [Trimestre], type text),
    OrdenAñoTrimestre = Table.AddColumn(AñoTrimestre, "OrdenAñoTrimestre", each [Año]*10+Date.QuarterOfYear([Fecha]), Int64.Type),
    Semestre = Table.AddColumn(OrdenAñoTrimestre, "Semestre", each if  [Mes] <= 6 then "Semestre 1" else "Semestre 2", type text),
    AñoSemestre = Table.AddColumn(Semestre, "Año Semestre", each Number.ToText([Año]) & "-" & [Semestre], type text),
    OrdenAñoSemestre = Table.AddColumn(AñoSemestre, "OrdenAñoSemestre", each [Año]*10 + Number.FromText(Text.End([Semestre],1)), Int64.Type),
    PrimerDíaSemana = Table.AddColumn(OrdenAñoSemestre, "PrimerDíaSemana", each Date.StartOfWeek([Fecha]), type date),
    ÚltimoDíaSemana = Table.AddColumn(PrimerDíaSemana, "ÚltimoDíaSemana", each Date.EndOfWeek([Fecha]), type date),
    PrimerDíaMes = Table.AddColumn(ÚltimoDíaSemana, "PrimerDíaMes", each Date.StartOfMonth([Fecha]), type date),
    ÚltimoDíaMes = Table.AddColumn(PrimerDíaMes, "ÚltimoDíaMes", each Date.EndOfMonth([Fecha]), type date),
    PrimerDíaTrimestre = Table.AddColumn(ÚltimoDíaMes, "PrimerDíaTrimestre", each Date.StartOfQuarter([Fecha]), type date),
    ÚltimoDíaTrimestre = Table.AddColumn(PrimerDíaTrimestre, "ÚltimoDíaTrimestre", each Date.EndOfQuarter([Fecha]), type date),
    PrimerDíaAño = Table.AddColumn(ÚltimoDíaTrimestre, "PrimerDíaAño", each Date.StartOfYear([Fecha]), type date),
    ÚltimoDíaAño = Table.AddColumn(PrimerDíaAño, "ÚltimoDíaAño", each Date.EndOfYear([Fecha]), type date),
    Semana = Table.AddColumn(ÚltimoDíaAño, "Semana", each "Sem " & Number.ToText(Date.WeekOfYear([Fecha])), type text),
    OrdenSemana = Table.AddColumn(Semana, "OrdenSemana", each Date.WeekOfYear([Fecha]), Int64.Type),
    AñoSemana = Table.AddColumn(OrdenSemana, "AñoSemana", each Number.ToText([Año]) & "-" & [Semana], type text),
    OrdenAñoSemana = Table.AddColumn(AñoSemana, "OrdenAñoSemana", each [Año]*100+[OrdenSemana], Int64.Type),
    #"Laborable/Festivo" = Table.AddColumn(OrdenAñoSemana, "Laboral/FinSemana", each if [DíaSemana] <= 5 then "Laborable" else "Festivo", type text),
    CuentaLaborable = Table.AddColumn(#"Laborable/Festivo", "CuentaLaborable", each if [DíaSemana] <= 5 then 1 else 0, Int64.Type),
    CuentaFinDeSemana = Table.AddColumn(CuentaLaborable, "CuentaFinDeSemana", each if [DíaSemana] <= 5 then 0 else 1, Int64.Type),
    Estaciones = Table.AddColumn(CuentaFinDeSemana, "Estacion", each if Number.FromText(Date.ToText([Fecha],"MMdd")) < 0320 then "INVIERNO" else 
if Number.FromText(Date.ToText([Fecha],"MMdd")) < 0621 then "PRIMAVERA" else
if Number.FromText(Date.ToText([Fecha],"MMdd")) < 0921 then "VERANO" else
if Number.FromText(Date.ToText([Fecha],"MMdd")) < 1221 then "OTOÑO" else "INVIERNO", type text),
    DíasInicioAño = Table.AddColumn( Estaciones, "DíasInicioAño", each Duration.Days([Fecha] - [PrimerDíaAño])+1, Int64.Type),
    DíasFinAño = Table.AddColumn ( DíasInicioAño, "DíasFinAño", each Duration.Days ([ÚltimoDíaAño]-[Fecha]), Int64.Type),
    DesvíoDías = Table.AddColumn(DíasFinAño, "DesvíoDías", each Duration.Days([Fecha]-vHoy), Int64.Type),
    DesvíoMes = Table.AddColumn(DesvíoDías, "DesvíoMes", each (([Año]-Date.Year(vHoy))*12)+([Mes]-Date.Month(vHoy)), Int64.Type),
    DesvíoTrimestre = Table.AddColumn(DesvíoMes, "DesvíoTrimestre", each (([Año]-Date.Year(vHoy))*4+Date.QuarterOfYear([Fecha])-Date.QuarterOfYear(vHoy)), Int64.Type),
    DesvíoAño = Table.AddColumn(DesvíoTrimestre, "DesvíoAño", each [Año]-Date.Year(vHoy), Int64.Type),
    Periodo = Table.AddColumn(DesvíoAño, "Periodo", each if [Fecha] <= vHoy then "PASADO" else "FUTURO", type text)
in
    Periodo