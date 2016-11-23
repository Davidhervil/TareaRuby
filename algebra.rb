require 'singleton'

class Interval
	attr_reader :izq, :der, iz_in:, de_in:
	# Verificar si es mejor hacer las inclusiones con un numero
	# y sumarselo siempre
end

class Literal < Interval
	def initialize izq, der, iz_in = 0, de_in = 0
		@izq = izq
		@der = der
	end
end

class RightInfinite < Interval
	def initialize izq, iz_in = 0
		@izq = izq
		@der = Float::INFINITY
		@de_in = -1
	end
end

class LeftInfinite < Interval
	def initialize der, de_in = 0
		@der = der
		@izq = -(Float::INFINITY)
		@iz_in = 1
	end
end

class AllReals < Interval
	include Singleton
	@izq = -(Float::INFINITY)
	@der = Float::INFINITY
	@iz_in = 1
	@de_in = -1
end

class Empty < Interval
	include Singleton
	@izq = 1
	@der = -1
end
