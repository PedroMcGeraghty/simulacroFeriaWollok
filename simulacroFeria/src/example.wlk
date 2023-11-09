class Feria{
	var property puestos = []
	
	method visito(visitante) = self.puestos().any({puesto=>puesto.usado().contains(visitante)})

	method municipiosApadrinantes() = puestos.map({ puesto => puesto.municipio() }).asSet().asList()
	
	method cuantosApadrina(municipio) = puestos.count({ puesto => puesto.municipio().equals(municipio) })
	
	method promedioRecaudacioinMunicipios() = self.municipiosApadrinantes().sum({ municipio => municipio.recaudado() }) / self.cantidadDeMunicipios()
	
	method cantidadDeMunicipios() = self.municipiosApadrinantes().size()

	method municipioQueMenosRecaudo() = self.municipiosApadrinantes().min({municipio=>municipio.recaudacion()})
}

class Visitante {
	var property dinero
	var property edad
	var property municipio
	var property deuda
	
	method puestosQuePuedoVisitar(feria) = feria.puestos().filter({puesto=>puesto.puedeSerUsado(self)})
	
	method ganarDinero(ganancia){
		dinero +=  ganancia
	}
	
	method gastarDinero(gasto){
		dinero -= gasto
	}
	
	method pagaDeuda(pago){
		deuda-=pago
	}
	
}

class Puesto{
	var property usado  = #{}
	var property municipio
	
	method puedeSerUsado(visitante)
	
	method usar(visitante){
		if(not self.puedeSerUsado(visitante)){
			throw new Exception(message = "No puedes visitar la atraccion")
		}
		self.usado().add(visitante)
	}
}

class PuestoInfantil inherits Puesto{
	
	override method puedeSerUsado(visitante) = visitante.edad() < 18
	
	override method usar(visitante){
		super(visitante)
		visitante.ganarDinero(10)
	}
}

class PuestoComercial inherits Puesto{
	
	var property costo
	
	override method puedeSerUsado(visitante) = visitante.dinero() > self.costo()
	
	override method usar(visitante){
		super(visitante)
		visitante.gastarDinero(self.costo())
	}	
}

class PuestosImpositivos inherits Puesto{
	
	method resideMismoMunicipio(visitante) = self.municipio() == visitante.municipio()
	
	method 	tieneDeuda(visitante) = visitante.deuda() > 0
	
	method puedePagar(visitante) =  visitante.dinero() >= self.municipio().montoExigible(visitante) 
	
	override method puedeSerUsado(visitante) = self.resideMismoMunicipio(visitante) and self.tieneDeuda(visitante) and self.puedePagar(visitante)
		
	override method usar(visitante) {
		super(visitante)
		visitante.gastarDinero(self.municipio().montoExigible(visitante))
		visitante.pagaDeuda(self.municipio().montoExigible(visitante))
		self.municipio().recaudado(self.municipio().montoExigible(visitante))
	}
}

class Municipio{
	var property recaudado
	method montoBruto(visitante)
	
	method montoProrrogable(visitante)
	
	method montoExigible(visitante) = self.montoBruto(visitante) - self.montoProrrogable(visitante)

	method recaudacion(monto){
		recaudado += monto
	}
}

class MunicipioNormales inherits Municipio{
	
	override method montoBruto(visitante) = visitante.deuda()
	
	override method montoProrrogable(visitante) = self.monto(visitante)
	
	method edad(visitante) = visitante.edad()>75 
	
	method monto(visitante){
		if(self.edad(visitante)){
			return self.montoBruto(visitante) * 0.1
		}
		return 0
	} 
}

class MunicipioRelajado inherits MunicipioNormales{
	
	override method montoBruto(visitante) = [visitante.deuda(),visitante.dinero()].min() 
	
}

class MunicipioHiperrelajado inherits MunicipioRelajado{
	
	override method montoBruto(visitante) = super(visitante)*0.80
	
	override method edad(visitante) = visitante.edad() > 60

	override method montoProrrogable(visitante) = super(visitante)* 2
	
}