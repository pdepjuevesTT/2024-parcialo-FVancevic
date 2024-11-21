class Persona {
    var formasDePago = []
    var formaDePagoPreferida
    var property cosas 
    var trabajo
    var cuentaBancaria
    var mesActual = 0
    //podria agregar algo de dinero circulante para cuando se cobra y que se use es para pagar las cosas y el dinero restante lo guarde en efectivo.cantidad(dineroRestante), es facil

    method comprar(cosa) {
        self.pagar(cosa)
        cosas.add(cosa)
        }

    method cambiarFormaDePagoPreferida(nuevaFormaPreferida) {
        if(formasDePago.contains(nuevaFormaPreferida)){
            formaDePagoPreferida = nuevaFormaPreferida
        }
    }

    method cobrar() {
        cuentaBancaria.cantidadDinero(cuentaBancaria.cantidadDinero() + trabajo.salario())
    }

    method pagar(cosa) = formaDePagoPreferida.pagar(cosa)

    method pasarMes() {
        self.cobrar()
        if(self.hayPagosPendientes()){
            self.cosasSinPagar().forEach{cosaSinPagar => formaDePagoPreferida.pagar(cosaSinPagar)}
        }
        mesActual +=1
    }



    method cosasSinPagar() = cosas.filter{cosa => !cosa.estaPagada()}

    method hayPagosPendientes() = formasDePago.any{formaDePago => formaDePago.cuotasPendientes() > 0}
}

class Trabajo {
    var property salario

    method salario(nuevoSalario) {
        if(nuevoSalario > salario) {
            salario = nuevoSalario
        }
    }

    method salario() = salario
}

class Cosa {
    var nombre
    var valor
    var property valorActual = valor

    var property estaPagada = false

    method nombre() = nombre

    method valor() = valor

    method faltaPagar() = valorActual
}

class FormaDePago {
    method puedePagar(cosa)
    method pagar(cosa)

}

class Efectivo inherits FormaDePago {
    var property cantidad

    override method puedePagar(cosa) = cantidad >= cosa.valor()

    override method pagar(cosa) {
        if(self.puedePagar(cosa)) {
            cantidad = cantidad - cosa.valorActual()
            cosa.estaPagada(true)
        }
    }

}


class Debito inherits FormaDePago{
    var property cuentaBancaria

    override method puedePagar(cosa) = cuentaBancaria.cantidadDinero() >= cosa.valor()

    override method pagar(cosa) {
        if(self.puedePagar(cosa)){
            cuentaBancaria.cantidadDinero(cuentaBancaria.cantidadDinero() - cosa.valorActual())
            cosa.estaPagada(true)
        } 
    }
}

class CuentaBancaria {
    var property cantidadDinero
}

class Credito inherits FormaDePago {
    var property cuentaBancaria
    var property bancoEmisor
    var cantidadDeCuotas
    var property cuotasPendientes
    var property cuotasVencidas = 0

    override method puedePagar(cosa) = bancoEmisor.maximoPermitido() >= cosa.valor()

    method cantidadAPagarMensualmente(cosa) = cosa.valor() / cantidadDeCuotas

    method cantidadAPagarMensualmenteConInteres(cosa) = self.cantidadAPagarMensualmente(cosa) * bancoEmisor.tasaDeInteres()


    override method pagar(cosa) {
        if(cuotasPendientes > 0 && self.puedePagar(cosa)) {
            cuentaBancaria.cantidadDinero(cuentaBancaria.cantidadDinero() - self.cantidadAPagarMensualmenteConInteres(cosa))
            cuotasPendientes -= 1
            cosa.valorActual(cosa.valorActual() - self.cantidadAPagarMensualmenteConInteres(cosa)) //esto da igual o menor a cero y esta bien
        } else if(cuotasPendientes > 0 && !self.puedePagar(cosa)) {
            cuotasVencidas =+ 1
        } else if(cuotasPendientes == 0){
            cosa.estaPagada(true)
        }
    }

}


//esta clase la podria sacar y agregarle los atributos a la clase Credito directamente
class Banco {
    var property maximoPerimitido

    var property tasaDeInteres
}


class CompradorCompulsivo inherits Persona{
    override method comprar(cosa){
        if(!formaDePagoPreferida.puedePagar(cosa) && formasDePago.any{formaDePago => formaDePago.puedePagar(cosa)}) {
            formasDePago.filter {formaDePago => formaDePago.puedePagar(cosa)}.get(0).comprar(cosa)
            cosas.add(cosa)
        }
    }
}

class PagadorCompulsivo inherits Persona {
    override method pagar(cosa) {
        if(!formaDePagoPreferida.puedePagar(cosa)){
            self.cambiarFormaDePagoPreferida(Efectivo)
        }
    }
}

class Personas {
    var personas = []

    method masCosasTiene() = personas.max{persona -> persona.cosas().size()}
}