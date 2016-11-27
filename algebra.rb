require 'singleton'

class Interval
	attr_reader :izq, :der, :izq_in, :der_in
	# Verificar si es mejor hacer las inclusiones con un numero
	# y sumarselo siempre CHECKED-RECHECKED
	def initialize izq, der, izq_in=true, der_in=true#Meter condiciones extra
		@izq = izq
		@der = der
		@izq_in = izq_in
		@der_in = der_in
		#OJO ARREGLAR
	end

	def to_s #Estar Pendiente de quitar los Infinity del print
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

	def empty?
		self == Empty.instance
	end

	def intersects? other
		if other == Empty.instance || self == Empty.instance
			return false
		else
			#puts "Al Principio"
			#Vemos si other esta dentro
			if self.izq < other.izq && other.izq < self.der
				return true
			elsif self.izq < other.izq && other.izq == self.der && self.der_in==true && other.izq_in==true
				#puts "Aqui"
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

	def empt? i, d, izn, den
		i>d || ( i == d && ( ((false == izn )== den) || ( izn != den )))
	end

	private :empt?
end

class Literal < Interval
	def initialize izq, der, izq_in = true, der_in = true
		if izq>der || izq == -(Float::INFINITY) || der == (Float::INFINITY) || (izq == der && ( izq_in!=der || (izq_in==false && der_in == false) ) )
			raise "Los argumentos introducidos no fueron los de un Literal."
		else
			@izq = izq
			@der = der
			@izq_in = izq_in
			@der_in = der_in
		end
	end

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

	def intersection_rightInfinite rinf
		self.intersection rinf
	end

	def intersection_leftInfinite linf
		self.intersection linf
	end

	def intersection_allReals allr #por ahora no
		self
	end

	def union other
		if self.unites? other
			other.union_literal self
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end

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

	def union_allReals allr #por ahora no
		AllReals.instance
	end
end

class RightInfinite < Interval
	def initialize izq, izq_in = true #Meter condiciones extra
		if izq == (Float::INFINITY) || izq == -(Float::INFINITY)
			raise "Los argumentos utilizados no son los de un RightInfinite"
		else
			@izq = izq
			@der = (Float::INFINITY)
			@izq_in = izq_in
			@der_in = false
		end
	end

	def intersection other
		if not(self.intersects?(other))
			Empty.instance
		else
			other.intersection_rightInfinite self
		end
	end

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

	def union other
		if self.unites? other
			other.union_rightInfinite self
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end

	def union_literal lit
		if self.unites? lit
			#Porque es lo mismo a copiar union_rightInfinite de Literal
			lit.union_rightInfinite self
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end

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

	def union_leftInfinite linf #por ahora no
		if self.unites? linf
			AllReals.instance
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end
end

class LeftInfinite < Interval
	def initialize der, der_in = true#Meter condiciones extra
		if der == (Float::INFINITY) || der == -(Float::INFINITY)
			raise "Los argumentos pasados no son los de un LeftInfinite"
		else
			@der = der
			@izq = -(Float::INFINITY)
			@izq_in = false
			@der_in = der_in
		end
	end

	def intersection other
		if not(self.intersects?(other))
			Empty.instance
		else
			other.intersection_leftInfinite self
		end
	end

	def intersection_rightInfinite rinf
		if self.intersects? rinf
			l = self.izq
			lin = self.izq_in
			d = rinf.der
			din = rinf.der_in
			Literal.new(l,d,lin,din)
		else
			Empty.instance
		end
	end

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

	def union other
		if self.unites? other
			other.union_leftInfinite self
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end

	def union_literal lit
		if self.unites? lit
			#Porque es lo mismo a copiar union_leftInfinite de Literal
			lit.union_leftInfinite self
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end

	def union_rightInfinite rinf
		if self.unites? rinf
			AllReals.instance
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end

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

class AllReals < Interval
	include Singleton
	def initialize#Meter condiciones extra
		@izq = -(Float::INFINITY)
		@der = (Float::INFINITY)
		@izq_in = false
		@der_in = false
	end

	def intersection other
		other
	end
	
	def intersection_rightInfinite rinf
		rinf
	end

	def intersection_leftInfinite linf
		linf
	end

	def union other
		if other == Empty.instance
			raise "No se puede unir con el intervalo vacio"
		else
			self
		end
	end

	def union_literal lit
		self
	end

	def union_rightInfinite rinf
		self
	end

	def union_leftInfinite linf
	end
end

class Empty < Interval
	include Singleton
	def initialize#Meter condiciones extra
	end

	def intersection other
		self
	end

	def union other
		raise "No se puede unir el intervalo vacio"
	end
end