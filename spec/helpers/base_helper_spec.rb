require File.dirname(__FILE__) + '/../spec_helper'

describe BaseHelper do
  # TODO: should maybe solved differently? since we're testing for implementation here, it might be worth some
  #   investigation ...
  describe "#link_to_section_main_action" do
    before(:each) do
      @site = stub_model(Site)
      @site.stub!(:to_param).and_return(1)
    end

    it "builds a link to Wikipages index if section is a Wiki" do
      @section = stub_model(Wiki)
      helper.should_receive(:admin_wikipages_path).with(@site, @section).and_return('/path/to/wikipages')
      helper.link_to_section_main_action(@site, @section)
    end

    it "builds a link to Articles index if section is a Blog" do
      @section = stub_model(Blog)
      helper.should_receive(:admin_articles_path).with(@site, @section).and_return('/path/to/articles')
      helper.link_to_section_main_action(@site, @section)
    end

    it "builds a link to Articles index if section is a Section" do
      @section = stub_model(Section)
      helper.should_receive(:admin_articles_path).with(@site, @section).and_return('/path/to/articles')
      helper.link_to_section_main_action(@site, @section)
    end
  end

  describe '#split_form_for' do
    before :each do
      @args = 'name', stub_model(Article), {:url => 'path/to/article'}
      @head = '<form action="path/to/article" method="post">'
      @form = "the form\n</form>"

      helper.stub!(:capture_erb_with_buffer).and_return "#{@head}\n#{@form}"
      helper.stub! :content_for
      helper.stub! :concat
    end

    it 'splits off the form head tag from the generated form' do
      _erbout = ''
      helper.should_receive(:concat).with('the form', anything())
      helper.split_form_for *@args do 'the form' end
    end

    it 'captures form head tag to content_for :form' do
      _erbout = ''
      helper.should_receive(:content_for).with(:form, @head)
      helper.split_form_for *@args do 'the form' end
    end
  end

  describe '#pluralize_str' do
    before :each do
      @singular = 'apple'
      @plural = 'apples'
      @singular_with_format = '%s apple'
    end

    it 'returns the singular of the passed string if count equals 1' do
      helper.pluralize_str(1, @singular, @plural).should == 'apple'
    end

    it 'returns the passed plural of the passed string if count equals 1 and a plural has been passed' do
      helper.pluralize_str(2, @singular, @plural).should == 'apples'
    end

    it "returns the passed singluar's pluralization if count equals 1 and no plural has been passed" do
      Inflector.should_receive(:pluralize).and_return 'cherries'
      helper.pluralize_str(2, @singular).should == 'cherries'
    end

    it 'interpolates the count to the returned result' do
      helper.pluralize_str(2, @singular_with_format).should == '2 apples'
    end
  end

  describe 'date helpers' do
    before :each do
      Time.zone.stub!(:now).and_return Time.local(2008, 1, 2)
      Time.zone.now.stub!(:yesterday).and_return Time.local(2008, 1, 1)
    end

    it '#todays_short_date returns a short formatted version of Time.zone.now' do
      helper.todays_short_date.should == 'January 2nd'
    end

    it '#yesterdays_short_date returns a short formatted version of Time.zone.now.yesterday' do
      helper.yesterdays_short_date.should == 'January 1st'
    end
  end

  it '#filter_options returns a nested array containing the installed column filters' do
    helper.filter_options.sort.should == [["Plain HTML", ""],
                                          ["Markdown", "markdown_filter"],
                                          ["Markdown with Smarty Pants", "smartypants_filter"],
                                          ["Textile", "textile_filter"]].sort
  end
end