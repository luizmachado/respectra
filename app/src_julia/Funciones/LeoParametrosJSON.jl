#leo valores iniciales del archivo SoloParametros.txt
#using Pkg; Pkg.add("JSON")

LeoParametros("SoloParametros.json")

println("Cef a ajustar: ",ParametrosCEFAAjustarTupla)
println("Cef a NO ajustar: ",ParametrosCEFANoAjustarTupla)
println("Acoplamientos a Ajustar: ", ParametrosJsAAjustarTupla)
println("Acoplamientos a NO Ajustar: ", ParametrosJsANoAjustarTupla)

println("Cantidad de variables a ajustar ", length(ParametrosCEFAAjustarTupla) + length(ParametrosJsAAjustarTupla) )

# dejo los parametros de CEF y Js en una unica tupla
CEFA = merge(ParametrosCEFAAjustarTupla,ParametrosCEFANoAjustarTupla)
trocas = merge(ParametrosJsAAjustarTupla,ParametrosJsANoAjustarTupla)
