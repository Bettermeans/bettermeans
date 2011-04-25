module GarconDsl
  def wait; GarconBuilder.new; end

  class GarconBuilder
    def for(timeout = 10)
      @timeout = timeout
      self
    end

    def until(&block)
      Garcon.new(1, @timeout).wait &block
    end
  end

  class Garcon
    def initialize(polling_period, timeout)
      @polling_period = polling_period
      @timeout = timeout
    end

    def wait(&block)
      fail("Missing block") unless block_given?

      started_at = Time.now
      done = false

      while !done do
        elapsed = (Time.now-started_at).seconds
        timeout elapsed
        done = block.call
        sleep @polling_period
      end
    end

    private

    def timeout(elapsed)      
      fail("Timed out after waiting for <#{elapsed}>.") if elapsed > @timeout
    end
  end
end