module AmiSpec
  class WaitForSSH
    def self.wait(ip_address, user, key, max_retries)
      last_error = nil
      retries = 0

      while retries < max_retries
        begin
          Net::SSH.start(ip_address, user, keys: [key], timeout: 5) { |ssh| ssh.exec 'echo boo!' }
        rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Timeout::Error => error
          last_error = error
        else
          break
        end

        retries = retries + 1
      end

      if retries > MAX_RETRIES - 1
        raise AmiSpec::InstanceConnectionTimeout.new("Timed out waiting for SSH to become available: #{last_error}")
      end
    end
  end
end
