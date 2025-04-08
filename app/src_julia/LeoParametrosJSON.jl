#leo valores iniciales del archivo SoloParametros.txt
#using Pkg; Pkg.add("JSON")

LeoParametros("SoloParametros.json")

println("Cef a ajustar: ",ParametrosCEFAAjustarTupla)
println("Cef a NO ajustar: ",ParametrosCEFANoAjustarTupla)
println("Acoplamientos a Ajustar: ", ParametrosJsAAjustarTupla)
println("Acoplamientos a NO Ajustar: ", ParametrosJsANoAjustarTupla)

println("Cantidad de variables a ajustar ", length(ParametrosCEFAAjustarTupla) + length(ParametrosJsAAjustarTupla) )
# pruebo la funcion
#Xs=CEFeJsToXs(ParametrosCEFAAjustarTupla,ParametrosJsAAjustarTupla)
#println("Xs: ", Xs)

# pruebo la funcion
#CEFNuevo, JsNuevo = XsToCEFeJs(Xs)
#println("CEFNuevo: ", CEFNuevo)
#println("JsNuevo: ", JsNuevo)
