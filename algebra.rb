#!/usr/bin/env ruby
require 'singleton'
##
# Clase padre que de los intervalos. No debe instanciarse. A menos que se especifique,
# la inclusión de los extremos reales de los intervalos es +true+ por defecto
class Interval
	##
	# Se decidió no permitir modificaciones en los parámetros de un intervalo
	# pues el cambiar alguno de los mismos implica un intervalo completamente
	# nuevo. Es por eso que los atributos son sólo readable.
	attr_reader :izq, :der, :izq_in, :der_in

	def initialize izq, der, izq_in=true, der_in=true#Meter condiciones extra
		puts "Advertencia, está instanciando un Interval. La correctitud de sus parámetros depende de USTED."
		puts "No tendrá metodos de subclases"
		@izq = izq
		@der = der
		@izq_in = izq_in
		@der_in = der_in
		#Hace falta verificar si estos estan correctos ?
	end

	##
	# Convierte a _printable_ un intervalo
	def to_s
		if self.empty?
			"empty"
		else
			if self.izq_in == true
				l='['
			else
				l='('
			end
			if self.der_in == true
				d = ']'
			else
				d = ')'
			end
			lcont = (self.izq!= -(Float::INFINITY)) ? self.izq.to_s : ''
			rcont = (self.der!= (Float::INFINITY)) ? self.der.to_s : ''
			l + lcont + ',' + rcont + d
		end
	end

	##
	# Predicado que dice si un intervalo es el intervalo vacío
	def empty?
		self == Empty.instance
	end

	##
	# Predicado que dice si el intervalo en cuestión intersecta (+true+) o no
	# (+false+) con el intervlo +other+.
	def intersects? other
		if other == Empty.instance || self == Empty.instance
			return false
		else
			#puts "Al Principio"
			#Vemos si other esta dentro
			if self.izq < other.izq && other.izq < self.der
				return true
			elsif self.izq < other.izq && other.izq == self.der && self.der_in==true && other.izq_in==true
				return true
			elsif self.izq == other.izq && self.izq_in==true && other.izq_in==true
				return true
			elsif self.izq == other.izq && self.izq_in==false && other.izq_in==false && other.izq < self.der
				return true
			elsif self.izq == other.izq && (self.izq_in!=other.izq_in)
				if self.der > self.izq && other.der > other.izq
					return true
				else
					return false
				end
			end
			#puts "En medio"
			#Sino
			#Vemos si self esta dentro
			if other.izq < self.izq && self.izq < other.der
				return true
			elsif other.izq < self.izq && self.izq == other.der && other.der_in==true && self.izq_in==true
				return true
			elsif other.izq == self.izq && other.izq_in==true && self.izq_in==true
				return true
			elsif other.izq == self.izq && other.izq_in==false && self.izq_in==false && self.izq < other.der
				return true
			elsif other.izq == self.izq && (other.izq_in!=self.izq_in)
				if other.der > other.izq && self.der > self.izq
					return true
				else
					return false
				end
			else
				return false
			end
		end
	end

	##
	# Predicado que dice si el intervalo en cuestión permite unión con el intervalo +other+
	def unites? other
		if self.intersects? other
			return true
		elsif other == Empty.instance || self == Empty.instance
			return false
		else
			if self.der < other.der
				minder = self.der
				minderin = self.der_in
			else
				minder = other.der
				minderin = other.der_in
			end

			if self.izq > other.izq
				maxizq = self.izq
				maxizqin = self.izq_in
			else
				maxizq = other.izq
				maxizqin = other.izq_in
			end

			if minder == maxizq #Si se rozan
				return maxizqin || minderin
			else
				return false
			end
		end
	end
end

##
# Clase que representa los intervalos acotados por ambos lados.
class Literal < Interval
	##
	# Por defecto +izq_in+ y +der_in+ son +true+. Es decir los extremos
	# del intervalo están incluidos. No se permite introducir parámetros
	# que describan intervalos diferentes a literales.
	def initialize izq, der, izq_in = true, der_in = true
		if izq>der || izq == -(Float::INFINITY) || der == (Float::INFINITY) || (izq == der && ( izq_in!=der_in || (izq_in==false && der_in == false) ) )
			raise "Los argumentos introducidos no fueron los de un Literal."
		else
			@izq = izq
			@der = der
			@izq_in = izq_in
			@der_in = der_in
		end
	end

	##
	# Método que retorna el intervalo resultante de intersectar con +other+.
	# Las intersecciones con +Literal+ siempre dan Literals o vacío.
	def intersection other
		if not(self.intersects?(other))
			Empty.instance
		else
			if self.izq == other.izq && (self.izq_in!=other.izq_in)
				l = self.izq
				lin = not(self.izq_in) ? self.izq_in : other.izq_in
			elsif self.izq >= other.izq
				l = self.izq
				lin = self.izq_in
			else
				l = other.izq
				lin = other.izq_in
			end

			if self.der == other.der && (self.der_in!=other.der_in)
				d = self.der
				din = not(self.der_in) ? self.der_in : other.der_in
			elsif self.der <= other.der
				d = self.der
				din = self.der_in
			else
				d = other.der
				din = other.der_in
			end
			Literal.new(l,d,lin,din)
		end
	end
	
	##
	# Método necesario para el doble despacho de intersecciones con +RightInfinite+s.
	def intersection_rightInfinite rinf
		self.intersection rinf
	end

	##
	# Método necesario para el doble despacho de intersecciones con +LeftInfinite+s.
	def intersection_leftInfinite linf
		self.intersection linf
	end

	##
	# Método que retorna el intervalo resultante, de ser así posible, de la 
	# unión con +other+. Si no es posible se arroja una exepción.
	def union other
		if self.unites? other
			other.union_literal self
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end

	##
	# Método necesario para el despacho doble de la unión con literales.
	# Se asume que +lit+ siempre es un +Literal+
	def union_literal lit
		if self.unites? lit
			if self.izq < lit.izq
				l = self.izq
				lin = self.izq_in
			elsif self.izq > lit.izq
				l = lit.izq
				lin = lit.izq_in
			else 
				l = self.izq
				if self.izq_in == lit.izq_in
					lin = self.izq_in
				else # CASO EN EL QUE SON IGUALES CON INCLUSION DIFERENTE. GANA true
					lin = self.izq_in ? self.izq_in : lit.izq_in
				end
			end

			if self.der > lit.der
				d = self.der
				din = self.der_in
			elsif self.der < lit.der
				d = lit.der
				din = lit.der_in
			else 
				d = self.der
				if self.der_in == lit.der_in
					din = self.der_in
				else # CASO EN EL QUE SON IGUALES CON INCLUSION DIFERENTE. GANA true
					din = self.der_in ? self.der_in : lit.der_in
				end
			end
			Literal.new(l,d,lin,din)
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end

	##
	# Método necesario para el despacho doble de la unión con +RightInfinite+s.
	def union_rightInfinite rinf
		if self.unites? rinf
			if self.izq < rinf.izq
				l = self.izq
				lin = self.izq_in
			elsif self.izq > rinf.izq
				l = rinf.izq
				lin = rinf.izq_in
			else 
				l = self.izq
				if self.izq_in == rinf.izq_in
					lin = self.izq_in
				else # CASO EN EL QUE SON IGUALES CON INCLUSION DIFERENTE. GANA true
					lin = self.izq_in ? self.izq_in : rinf.izq_in
				end
			end
			RightInfinite.new(l,lin)
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end

	##
	# Método necesario para el despacho doble de la unión con +LeftInfinite+s.
	def union_leftInfinite linf
		if self.unites? linf
			if self.der > linf.der
				d = self.der
				din = self.der_in
			elsif self.der < linf.der
				d = linf.der
				din = linf.der_in
			else 
				d = self.der
				if self.der_in == linf.der_in
					din = self.der_in
				else # CASO EN EL QUE SON IGUALES CON INCLUSION DIFERENTE. GANA true
					din = self.der_in ? self.der_in : linf.der_in
				end
			end
			LeftInfinite.new(d,din)
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end 
	end
end

##
# Clase que representa los intervalos no acotados por la derecha.
class RightInfinite < Interval
	##
	# Si se introducen argumentos que describan intervalos diferentes a un
	# +RightInfinite+ se genera una expeción.
	def initialize izq, izq_in = true
		if izq == (Float::INFINITY) || izq == -(Float::INFINITY)
			raise "Los argumentos utilizados no son los de un RightInfinite"
		else
			@izq = izq
			@der = (Float::INFINITY)
			@izq_in = izq_in
			@der_in = false
		end
	end

	##
	# Método que retorna el intervalo resultante de intersectar con +other+.
	# Se implementa con doble despacho.
	def intersection other
		if not(self.intersects?(other))
			Empty.instance
		else
			other.intersection_rightInfinite self
		end
	end

	##
	# Método necesario para el doble despacho de intersecciones con +RightInfinite+s.
	def intersection_rightInfinite rinf
		if self.izq > rinf.izq
			l = self.izq
			lin = self.izq_in
		elsif self.izq == rinf.izq
			l = self.izq
			lin = not(self.izq_in) ? self.izq_in : rinf.izq_in
		else
			l = rinf.izq
			lin = rinf.izq_in
		end
		RightInfinite.new(l,lin)
	end

	##
	# Método necesario para el doble despacho de intersecciones con +LeftInfinite+s.
	def intersection_leftInfinite linf
		if self.intersects? linf
			l = self.izq
			lin = self.izq_in
			d = linf.der
			din = linf.der_in
			Literal.new(l,d,lin,din)
		else
			Empty.instance
		end
	end

	##
	# Método que retorna el intervalo resultante, de ser así posible, de la 
	# unión con +other+. Si no es posible se arroja una exepción.
	def union other
		if self.unites? other
			other.union_rightInfinite self
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end

	##
	# Método necesario para el despacho doble de la unión con literales.
	# Se asume que +lit+ siempre es un +Literal+
	def union_literal lit
		if self.unites? lit
			#Porque es lo mismo a copiar union_rightInfinite de Literal
			lit.union_rightInfinite self
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end

	##
	# Método necesario para el despacho doble de la unión con +RightInfinite+s.
	def union_rightInfinite rinf
		if self.izq < rinf.izq
			l = self.izq
			lin = self.izq_in
		elsif self.izq > rinf.izq
			l = rinf.izq
			lin = rinf.izq_in
		else 
			l = self.izq
			if self.izq_in == rinf.izq_in
				lin = self.izq_in
			else # CASO EN EL QUE SON IGUALES CON INCLUSION DIFERENTE. GANA true
				lin = self.izq_in ? self.izq_in : rinf.izq_in
			end
		end
		RightInfinite.new(l,lin)
	end

	##
	# Método necesario para el despacho doble de la unión con +LeftInfinite+s.
	def union_leftInfinite linf
		if self.unites? linf
			AllReals.instance
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end
end

##
# Clase que representa los intervalos no acotados po la izquierda.
class LeftInfinite < Interval
	##
	# Si se introducen argumentos que describan intervalos diferentes a un
	# +LeftInfinite+ se genera una expeción.
	def initialize der, der_in = true
		if der == (Float::INFINITY) || der == -(Float::INFINITY)
			raise "Los argumentos pasados no son los de un LeftInfinite"
		else
			@der = der
			@izq = -(Float::INFINITY)
			@izq_in = false
			@der_in = der_in
		end
	end

	##
	# Método que retorna el intervalo resultante de intersectar con +other+.
	# Se implementa con doble despacho.
	def intersection other
		if not(self.intersects?(other))
			Empty.instance
		else
			other.intersection_leftInfinite self
		end
	end

	##
	# Método necesario para el doble despacho de intersecciones con +RightInfinite+s.
	def intersection_rightInfinite rinf
		if self.intersects? rinf
			d = self.der
			din = self.der_in
			l = rinf.izq
			lin = rinf.izq_in
			#puts [l ,d, lin, din]
			Literal.new(l,d,lin,din)
		else
			Empty.instance
		end
	end

	##
	# Método necesario para el doble despacho de intersecciones con +LeftInfinite+s.
	def intersection_leftInfinite linf
		if self.der < linf.der
			d = self.der
			din = self.der_in
		elsif self.der == linf.der
			d = self.der
			din = not(self.der_in) ? self.der_in : linf.der_in
		else
			d = linf.der
			din = linf.der_in
		end
		LeftInfinite.new(d,din)
	end

	##
	# Método que retorna el intervalo resultante, de ser así posible, de la 
	# unión con +other+. Si no es posible se arroja una exepción.
	def union other
		if self.unites? other
			other.union_leftInfinite self
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end

	##
	# Método necesario para el despacho doble de la unión con literales.
	# Se asume que +lit+ siempre es un +Literal+
	def union_literal lit
		if self.unites? lit
			#Porque es lo mismo a copiar union_leftInfinite de Literal
			lit.union_leftInfinite self
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end

	##
	# Método necesario para el despacho doble de la unión con +RightInfinite+s.
	def union_rightInfinite rinf
		if self.unites? rinf
			AllReals.instance
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end

	##
	# Método necesario para el despacho doble de la unión con +LeftInfinite+s.
	def union_leftInfinite linf
		if self.der > linf.der
			d = self.der
			din = self.der_in
		elsif self.der < linf.der
			d = linf.der
			din = linf.der_in
		else 
			d = self.der
			if self.der_in == linf.der_in
				din = self.der_in
			else # CASO EN EL QUE SON IGUALES CON INCLUSION DIFERENTE. GANA true
				din = self.der_in ? self.der_in : linf.der_in
			end
		end
		LeftInfinite.new(d,din)
	end
end

##
# Case que reprsenta el intervalo de todos los números Reales.
class AllReals < Interval
	include Singleton
	##
	# Se implantó con el mixin +Singleton+ para aprovechar el patrón singletón.
	# Esdecir, sólo hay una instancia en el progama. Por eso para _accederle_ 
	# debe hacerse de la forma +AllReals.instance+.
	def initialize
		@izq = -(Float::INFINITY)
		@der = (Float::INFINITY)
		@izq_in = false
		@der_in = false
	end

	##
	# Método de intersección con todos los reales. Notar que el realizar esto es
	# lo mismo a +other+
	def intersection other
		other
	end
	
	##
	# Método necesario para el doble despacho de intersecciones con +RightInfinite+s.
	def intersection_rightInfinite rinf
		rinf
	end

	##
	# Método necesario para el doble despacho de intersecciones con +LeftInfinite+s.
	def intersection_leftInfinite linf
		linf
	end

	##
	# Método que retorna de ser posible el intervalo resultante de unir con +other+.
	# Notar que eso es lo mismo a devolver todos los reales en este caso.
	def union other
		if other == Empty.instance
			raise "No se puede unir con el intervalo vacío"
		else
			self
		end
	end

	##
	# Método necesario para el despacho doble de la unión con literales.
	# Se asume que +lit+ siempre es un +Literal+
	def union_literal lit
		self
	end

	##
	# Método necesario para el despacho doble de la unión con +RightInfinite+s.
	def union_rightInfinite rinf
		self
	end

	##
	# Método necesario para el despacho doble de la unión con +LeftInfinite+s.
	def union_leftInfinite linf
		self
	end
end

##
# Clase que representa el intervalo vacío
class Empty < Interval
	include Singleton
	##
	# Se implantó con el mixin +Singleton+ para aprovechar el patrón singletón.
	# Esdecir, sólo hay una instancia en el progama. Por eso para _accederle_ 
	# debe hacerse de la forma +Empty.instance+.
	#
	# Esta clase no tiene ninguno de los métodos de despacho doble pues no los
	# necesita. El predicado +intersects?+ se encarga de que no haga falta. Así
	# la responsabilidad del programador por no llamar a los metodos de dobledespacho
	# con argumentos que inválidos.
	def initialize
	end

	##
	# Método que retorna el resultado de intersectar con +other+. Notar que eso
	# Siempre da vacío.
	def intersection other
		self
	end

	##
	# Método que *no* retorna \*wink wink\* la unión con el intervalo vacío
	def union other
		raise "No se puede unir el intervalo vacío"
	end
end

##
# Método que recibe un +Array+ de Strings de la forma\:
# 	[ _variable_, _operador-comparación_, _numero_ ]
# y devuelve el intervalo asociado a esa expresión.
def obtener_intervalo expresion
	operador = 1
	numero = 2
	if expresion[operador] == "<"
		n = expresion[numero].to_f
		LeftInfinite.new(n,false)

	elsif expresion[operador] == ">"
		n = expresion[numero].to_f
		RightInfinite.new(n,false)
	
	elsif expresion[operador] == "<="
		n = expresion[numero].to_f
		LeftInfinite.new(n,true)
	
	elsif expresion[operador] == ">="
		n = expresion[numero].to_f
		RightInfinite.new(n,true)
	
	elsif expresion [operador] == "=="
		n = expresion[numero].to_f
		Literal.new(n,n)
	else
		raise "Operador inválido: #{expresion [operador]}"
	end		
end

##
# Procedimiento que muestra en pantalla el +par+ variable-intervalo
def mostrar par
	if par[1].izq == par[1].der && par[1]!=Empty.instance
		puts "#{par[0]} is excatly #{par[1].der}"
	else
		puts "#{par[0]} in #{par[1]}"
	end
end

##
# Procedimiento principal de la calculadora
# *Notar* que las expresiones del archivo de tipo:
# 	_variable_ _operador-comparación_ _numero_
# La variable, operador de comparación y el número *deben* estar separadas por espacio.
def main
	if ARGV.length !=1
		puts "Error, número de argumentos invalido"
	else
		f = File.open(ARGV[0],"r")
		variables = Hash.new(AllReals.instance) #Tabla de Símbolos
		
		#A cada linea hacerle split por '|' eso las separa las operaciones con la precedencia correcta.
		#Luego a cada una de esas separarlas por '&' y optener y aplicar las expresiones

		variable = 0
		while line = f.gets #Procesamiento de archivo
			ortemp = Hash.new(AllReals.instance)
			ors_op = line.split(/[\s]*\|[\s]*/)#Separamos los or. Estar pendiente por si la estrella de klein no es
			for orop in ors_op
				andtemp = Hash.new(AllReals.instance) #diccionario auxiliar de los and
				ands_op = orop.split(/[\s]*&[\s]*/)#Separamos los and
				
				for andop in ands_op
					expresion = andop.split(/[\s]+/)#Asumimos que tiene los espacios, sino hay que recorrer manual
					if andtemp.has_key? expresion[variable]
						interv = obtener_intervalo(expresion)
						#Obtenemos intervalo y le hacemos el and respectivo						
						andtemp[expresion[variable]] = andtemp[expresion[variable]].intersection(interv)
					else
						andtemp[expresion[variable]] = obtener_intervalo(expresion)
					end
				end
				#Una vez terminado el término de conjunción procedemos a operar la disyuncion
				ortemp = ortemp.merge(andtemp){|key,orval,andval| orval.union andval}
			end
			#Luego de procesada la línea, se hace el or con el resto.
			variables = variables.merge(ortemp){|key,varval,orval| varval.union orval}
		end
		f.close
		#Mostramos los resultados
		for pair in variables
			mostrar pair
		end
		#Linea de comandos
		puts "Las operaciones que realice no alterarán el estado de las variables."
		while true
			print ">> "
			command = STDIN.gets.chomp
			if command == "exit"
				break
			else
				ors_op = command.split(/[\s]*\|[\s]*/)#Estar pendiente por si la estrella de klein no es
				result = nil
				error = false
				for orop in ors_op
					andaux = AllReals.instance
					ands_op = orop.split(/[\s]*&[\s]*/)#parece que no hay que escapear el and
					for var in ands_op
						if variables.has_key? var
							andaux = andaux.intersection(variables[var])	
						else
							puts "La variable '#{var}' no existe."
							error = true
							break
						end
					end
					if not(error)
						result = result ? (result.union andaux) : andaux
					else
						break
					end
				end
				if not(error)
					puts result
				end
			end
		end
	end
end

main