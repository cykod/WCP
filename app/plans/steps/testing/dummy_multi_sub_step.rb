
class Steps::Testing::DummyMultiSubStep < Steps::Base

  step_info "(Z) Noop Step that doesn't actually do anything", :substeps => 2

  class Options < HashModel

  end

  def execute!(step)

  end


  def finished?(step)
    true
  end

end


