require 'singleton'

class Interval
	attr_reader :izq, :der, :izq_in, :der_in
	# Verificar si es mejor hacer las inclusiones con un numero
	# y sumarselo siempre CHECKED-RECHECKED
	def initialize izq, der, izq_in=true, der_in=true
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
			l + self.izq.to_s + ',' + self.der.to_s + d
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
				puts maxizqin || minderin
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
		@izq = izq
		@der = der
		@izq_in = izq_in
		@der_in = der_in
	end

	def intersection other
		if other == Empty.instance || not(self.intersect?(other))
			Empty.instance
		else
			if self.izq == other.izq && (self.izq_in!=other.izq_in)
				l = self.izq
				lin = not(self.izq_in)? self.izq_in : other.izq_in
			elsif self.izq >= other.izq
				l = self.izq
				lin = self.izq_in
			else
				l = other.izq
				lin = other.izq_in
			end

			if self.der == other.der && (self.der_in!=other.der_in)
				d = self.der
				din = not(self.der_in)? self.der_in : other.der_in
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

	def union other
		if self.unites? other
			other.union_literal
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end

	def union_literal other
		if self.unites? other
			#No he comenzado
			if self.izq < other.izq
				l = self.izq
				lin = self.izq_in
			else
				l = other.izq
				lin = other.izq_in #OJO QUE FALTA EL CASO EN EL QUE SON IGUALES CON NICLUSION DIFERENTE. GANA true
			end

			if self.der > other.der
				d = self.der
				din = self.der_in
			else
				d = other.der
				din = other.der_in#OJO QUE FALTA EL CASO EN EL QUE SON IGUALES CON NICLUSION DIFERENTE. GANA true
			end
			Literal.new(l,d,lin,din)
		else
			raise "Los intervalos no se intersectan ni cumplen con (a, b) U [b, c] = (a, c]"
		end
	end
	union_literal
end

class RightInfinite < Interval
	def initialize izq, izq_in = true
		@izq = izq
		@der = Float::INFINITY
		@der_in = false
		@izq_in = izq_in
	end

	def intersection other
	
	end

	def union other

	end
end

class LeftInfinite < Interval
	def initialize der, der_in = true
		@der = der
		@izq = -(Float::INFINITY)
		@izq_in = false
		@der_in = der_in
	end

	def intersection other
	
	end

	def union other

	end
end

class AllReals < Interval
	include Singleton
	def initialize
		@izq = -(Float::INFINITY)
		@der = Float::INFINITY
		@izq_in = false
		@der_in = false
	end

	def intersection other
	
	end

	def union other

	end
end

class Empty < Interval
	include Singleton
	def initialize
	end

	def intersection other
	
	end

	def union other

	end
end
