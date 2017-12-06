##
# A class for brute forcing digest and handing them over to subjects
# which analyse and in some way process them.
# Subjects need to implement HashBruteBaseSubject API.
# +check_finished_every+: if set to a number, only every number cycles
#     subjects will be checked for finished
class HashBrute
  def initialize(
    salt:,
    digest_klass: :MD5,
    digest_type: :hexdigest,
    check_finished_every: 10_000,
    print_progress_every: 100_000
  )
    @salt = salt
    @subjects = []
    @digest_klass = digest_klass
    @digest_type = digest_type
    @digester = Digest.const_get(@digest_klass)
    @check_finished_every = check_finished_every
    @print_progress_every = print_progress_every
  end

  ##
  # Adding a subject that gets the created digest handed over
  # to perform its checks and create the password
  def add_subject(subject)
    @subjects << subject unless @subjects.include?(subject)
  end

  ##
  # Start the thing
  def run
    # Work with a local copy of the subjects array because we want to
    # stop handling a subject once it finished
    test_subjects = @subjects.clone
    # We loop as long as there is a subject that is not finishd
    index = 0
    until test_subjects.size.zero?
      # Create digest, hand over to each subject and increase index counter
      digest = @digester.send(@digest_type, @salt + index.to_s)
      test_subjects.each { |s| s.take(digest: digest, index: index) }

      remove_finished(index: index, subjects: test_subjects)
      print_progress(index: index, subjects: test_subjects)

      index += 1
    end
  end

  ##
  # Remove subject from given +subjects+ it is finished
  private def remove_finished(index:, subjects:)
    # only check every so many rounds
    if @check_finished_every && (index % @check_finished_every) > 0
      return subjects
    end
    orig_subjects = subjects.clone
    remaining = subjects.delete_if(&:finished?)
    # Return if nothing was deleted
    return subjects if remaining.size == orig_subjects.size
    # Print deleted items
    puts "\nHashBrute: index=#{index}:\n"
    (orig_subjects - remaining).each do |s|
      puts "  Subject Finished: #{s.verbose_result}\n"
    end
    puts ''
    remaining
  end

  ##
  # Just print the progress so far for +index+ and +subjects+
  private def print_progress(index:, subjects:)
    return if @print_progress_every && (index % @print_progress_every) > 0
    puts "\nHashBrute: index=#{index}:\n"
    subjects.each { |s| puts "  Subject: #{s.verbose_result}" }
    puts ''
  end

  module BaseSubject
    def take(digest:, index:)
      raise "#{self.class} missing #take"
    end

    def finished?
      raise "#{self.class} missing #finished?"
    end

    def verbose_result
      raise "#{self.class} missing #verbose_result"
    end
  end
end
