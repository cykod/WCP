 class StepException < RuntimeError
   attr :description
   def initialize(desc)
     @description = desc
   end
 end

