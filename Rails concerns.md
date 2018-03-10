About Rails concerns

> TL;DR. Don’t use Rails concerns.
Introduction

If you are an experienced Rails developer, you won’t need explanations about what a concern is. For those who are new to the framework, here is a short explanation:

    The Concern is a tool provided by the ActiveSupport lib for including modules in classes, creating mixins.

  module Emailable
    include ActiveSupport::Concern

    def deliver(email)
      # send email here... 
    end
  end

  class Document
    include Emailable

    def archive
      @archived = true
      deliver({to: 'me@mydomain.com', subject: 'Document archived', body: @content})
    end
  end

Sounds great, right? Any class including our Emailable concern would be able to send emails. Unfortunately, not every example in a common Rails project is as clear as the one explained above.

In this post we’ll talk about some anti-patterns regarding Concerns, what problems can arise, and how we can solve them.
