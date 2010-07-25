class Steps::Simple::DummyStep < Steps::Base

  step_info "Noop Step that doesn't actually do anything", :substeps => 1

  class Options < HashModel

  end

  def execute!(step)

  end


  def finished?(step)
    true
  end

end


