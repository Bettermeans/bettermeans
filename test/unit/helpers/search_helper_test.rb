# encoding: utf-8
#
# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../../test_helper'

class SearchHelperTest < HelperTestCase
  include SearchHelper

  def test_highlight_single_token
    assert_equal 'This is a <span class="highlight token-0">token</span>.',
                 highlight_tokens('This is a token.', %w(token))
  end

  def test_highlight_multiple_tokens
    assert_equal 'This is a <span class="highlight token-0">token</span> and <span class="highlight token-1">another</span> <span class="highlight token-0">token</span>.',
                 highlight_tokens('This is a token and another token.', %w(token another))
  end

  def test_highlight_should_not_exceed_maximum_length
    s = (('1234567890' * 100) + ' token ') * 100
    r = highlight_tokens(s, %w(token))
    assert r.include?('<span class="highlight token-0">token</span>')
    assert r.length <= 1300
  end

  def test_highlight_multibyte
    s = ('й' * 200) + ' token ' + ('й' * 200)
    r = highlight_tokens(s, %w(token))
    assert_equal  ('й' * 45) + ' ... ' + ('й' * 44) + ' <span class="highlight token-0">token</span> ' + ('й' * 44) + ' ... ' + ('й' * 45), r
  end
end
