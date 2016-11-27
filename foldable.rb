##
# Este mixin representa el comprotamiento de _Plegado_.
# Se asume que la clase donde se vaya a incluir tiene el método +foldr+
module Fold
    ##
    # Predicado que dice si la estructura plegable está vacia (+true+)
    # o no (+false+)
    def null?
        self.foldr(true) {|a| false}
    end
    
    ##
    # Método que recibe un bloque y utiliza de valor base para el plegado
    # el úiltimo elemento de la estructura plegable.
    def foldr1 &block
        if not self.null?
            self.foldr(nil) {|e,ac| ac ? block.call(e,ac) : e}
        else
            raise "Estructura vacia"
        end
    end

    ##
    # Método que calcula la longitud de la estructura plegable
    def length
        self.foldr(0) { |e,ac| ac+1 }
    end
    
    ##
    # Predicado que dice si todos los elementos de la estructura plegable
    # cumplen con el predicado bloque de argumento
    def all? &block
        self.foldr(true) { |e,ac| ac && block.call(e)}
    end
    
    ##
    # Predicado que dice si alguno los elementos de la estructura plegable
    # cumple con el predicado bloque de argumento
    def any? &block
        self.foldr(false) { |e,ac| ac || block.call(e)}
    end
    
    ##    
    # Método que devuelve un +Array+ con el resultado de aplanar mediante
    # +foldr+ la estructura plegable
    def to_arr
        self.foldr([]) { |e,ac| ac.unshift(e)}
    end
    
    ##
    # Predicado que dice si el elemento +to_find+ pertenece o no a la estructura
    # plegable.
    def elem? to_find
        self.any? { |e| e == to_find}
    end
end

##
# Adicíon del método +foldr+ a la clase +Array+
# Se asume que la clase donde se vaya a incluir tiene el método +foldr+
class Array
    include Fold
    ##
    # El método +foldr+ recibe un valor base +e+ y un bloque +b+ el cual se
    # asume como un f \:\: a -> b -> b donde _a_ es el tipo base de la lista a plegar.
    # Retorna el valor de haber aplicado f(elem1, f(elem2,...f(elemn,e))).
    def foldr e, &b 
        #reverse.inject(e) { |acum,elem| elem.send(b,acum)}
        #Otra posible opcion es invertir el arreglo y hacerle fold norml con un ciclo.
        n = self.length
        if n>=1
            b.call(self.first,self.last(n-1).foldr(e,&b))
        else
            e
        end
    end
end

##
# Clase que representa un Árbol n-ario
class Rose
    include Fold
    attr_accessor :elem, :children
    ##
    # Crea un nuevo árbol y de no recibir argumento +children+ por defecto es
    # la lista vacía. Notar que no puede haber un árbol vacío. Se aprovecho ese
    # aspecto en la implementación del +foldr+.
    def initialize elem, children = []
        @elem = elem
        @children = children
    end

    ##
    # Añade un nuevo elemento al árbol y retorna el árbol resultante.
    def add elem
        @children.push elem
        self
    end

    ##
    # El método +foldr+ recibe un valor base +e+ y un bloque +b+ el cual se
    # asume como un f \:\: a -> b -> b donde _a_ es el tipo base del árbol a plegar.
    # Retorna el valor de haber plegado el árbol desde el elemento más a la derecha
    # hasta el más a la izquierda
    def foldr e, &b
        # Su código aquí
        acum = e
        if self.children.length >= 1
            i=self.children.size - 1
            while i>=0
                acum = self.children[i].foldr(acum,&b)
                i -= 1
            end
        end

        b.call(self.elem, acum)
    end
    ##
    # Método que calcula el promedio de los elementos del árbol utilizando
    # +foldr1+ del mixin +Fold+.
    def avg
        total = 1.0
        suma = 0.0
        self.foldr1 {|e,a| total+=1; suma= a+e}
        suma/total
    end
end
'''
def main
    a = Rose.new(1, [Rose.new(2, [ Rose.new(4), Rose.new(5) ]),Rose.new(3, [ Rose.new(6) ])])
    b = [1,2,3,4,5,6]
    c = []
    puts a.foldr1 {|e,ac| e+ac} 
    puts " Suma arbol"
    puts b.foldr1 {|e,ac| e+ac} 
    puts " Suma areglo"
    puts a.null? 
    puts " Arbol null"
    puts b.null? 
    puts " Arreglo no vacio null"
    puts c.null? 
    puts " Arreglo vacio null"
    puts a.all? { |e| e>=1 } 
    puts " Arbol all true"
    puts a.all? { |e| e<1 } 
    puts " Arbol all false"
    puts b.all? { |e| e>=1 } 
    puts " Arreglo all true"
    puts b.all? { |e| e<1 } 
    puts " Arreglo all false"
    puts a.any? { |e| e==1 } 
    puts " Arbol any true"
    puts a.any? { |e| e<1 } 
    puts " Arbol any false"
    puts b.any? { |e| e==1 } 
    puts " Arreglo any true"
    puts b.any? { |e| e<1 } 
    puts " Arreglo any false"
    puts a.length #OJO WTF ESTE NO FUNCIONA
    puts " Arbol longitud"
    puts b.length 
    puts " Arreglo longitud"
    puts a.to_arr 
    puts " Arbol arreglo"
    puts b.to_arr 
    puts " Arreglo^2"
    puts a.elem? 3
    puts " Arbol busqueda true"
    puts b.elem? 3
    puts " Arreglo busqueda true"
    puts a.elem? 69 
    puts " Arbol busqueda false"
    puts b.elem? 69 
    puts " Arreglo busqueda false"
    return "Readixon"
end
'''