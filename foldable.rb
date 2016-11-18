class Array
    def foldr e, b
        #reverse.inject(e) { |acum,elem| elem.send(b,acum)}
        #Otra posible opcion es invertir el arreglo y hacerle fold norml con un ciclo.
        n = self.length
        if n>=2
            b.call(self.first,self.last(n-1).foldr(e,b))
        else
            b.call(self.first,e)
        end
    end
end

class Rose
    attr_accessor :elem, :children
    def initialize elem, children = []
        @elem = elem
        @children = children
    end
    def add elem
        @children.push elem
        self
    end
    def foldr e, b
        # Su código aquí
        if self.children.length >= 2
            b.call(self.elem,self.children.last(n-1).foldr())
    end
end

def main
end
