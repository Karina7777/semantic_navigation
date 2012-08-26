require 'spec_helper'

describe SemanticNavigation::Renderers::List do

  before :each do
  	class ViewObject
  	  attr_accessor :output_buffer
  	  include ActionView::Helpers::TagHelper
  	  include SemanticNavigation::HelperMethods
  	  include ActionView::Helpers::UrlHelper
  	end
    @configuration = SemanticNavigation::Configuration
  	@configuration.register_renderer :list, SemanticNavigation::Renderers::List
  	@view_object = ViewObject.new
  end

  it 'should render empty ul tag for empty navigation' do
  
    @configuration.run do
      navigate :menu do
      end
    end
    
    result = @view_object.navigation_for :menu
    result.should == "<ul class=\"list\" id=\"menu\"><\/ul>"
  end  

  it 'should render one level navigation' do
    @configuration.run do
      navigate :menu do
      	item :url1, 'url1', :name => 'url1'
      	item :url2, 'url2', :name => 'url2'
      end
    end

    result = @view_object.navigation_for :menu
    result.should == ["<ul class=\"list\" id=\"menu\">",
                        "<li id=\"url1\">",
                          "<a href=\"url1\" id=\"url1\">",
                            "url1",
                          "</a>",
                        "</li>",
                        "<li id=\"url2\">",
                          "<a href=\"url2\" id=\"url2\">",
                            "url2",
                          "</a>",
                         "</li>",
                      "</ul>"].join
  end

it 'should render one multilevel navigation' do
    @configuration.run do
      navigate :menu do
      	item :url1, 'url1', :name => 'url1' do
          item :suburl1, 'suburl1', :name => 'suburl1'
      	end
      	item :url2, 'url2', :name => 'url2' do
          item :suburl2, 'suburl2', :name => 'suburl2'
      	end
      end
    end

    result = @view_object.navigation_for :menu
    result.should == ["<ul class=\"list\" id=\"menu\">",
                        "<li id=\"url1\">",
                          "<a href=\"url1\" id=\"url1\">",
                            "url1",
                          "</a>",
                          "<ul id=\"url1\">",
                            "<li id=\"suburl1\">",
                              "<a href=\"suburl1\" id=\"suburl1\">",
                                "suburl1",
                              "</a>",
                            "</li>",
                          "</ul>",
                        "</li>",
                        "<li id=\"url2\">",
                          "<a href=\"url2\" id=\"url2\">",
                            "url2",
                          "</a>",
                          "<ul id=\"url2\">",
                            "<li id=\"suburl2\">",
                              "<a href=\"suburl2\" id=\"suburl2\">",
                                "suburl2",
                              "</a>",
                            "</li>",
                          "</ul>",
                        "</li>",
                      "</ul>"].join
  end  

  it 'should render only root level' do
    @configuration.run do
      navigate :menu do
      	item :url1, 'url1', :name => 'url1' do
          item :suburl1, 'suburl1', :name => 'suburl1'
      	end
      	item :url2, 'url2', :name => 'url2' do
          item :suburl2, 'suburl2', :name => 'suburl2'
      	end
      end
    end

    result = @view_object.navigation_for :menu, :level => 0
    result.should == ["<ul class=\"list\" id=\"menu\">",
                        "<li id=\"url1\">",
                          "<a href=\"url1\" id=\"url1\">",
                            "url1",
                          "</a>",
                        "</li>",
                        "<li id=\"url2\">",
                          "<a href=\"url2\" id=\"url2\">",
                            "url2",
                          "</a>",
                        "</li>",
                      "</ul>"].join  	
  end

  it 'should render second level if some item of first level is active' do
    @configuration.run do
      navigate :menu do
      	item :url1, 'url1', :name => 'url1' do
          item :suburl1, 'suburl1', :name => 'suburl1'
      	end
      	item :url2, 'url2', :name => 'url2' do
          item :suburl2, 'suburl2', :name => 'suburl2'
      	end
      end
    end

    @view_object.should_receive(:current_page?).and_return(false, true, false, false)

    result = @view_object.navigation_for :menu, :level => 1
    result.should == ["<ul class=\"list active\" id=\"menu\">",
                        "<li id=\"suburl1\">",
                          "<a href=\"suburl1\" id=\"suburl1\">",
                            "suburl1",
                          "</a>",
                        "</li>",
                      "</ul>"].join  	
  end

  it 'should render the exact levels' do
    @configuration.run do
      navigate :menu do
      	item :url1, 'url1', :name => 'url1' do
          item :suburl1, 'suburl1', :name => 'suburl1' do
          	item :subsub1, 'subsub1', :name => 'subsub1'
          end
      	end
      	item :url2, 'url2', :name => 'url2' do
          item :suburl2, 'suburl2', :name => 'suburl2' do
          	item :subsub2, 'subsub2', :name => 'subsub2'
          end
      	end
      end
    end

    result = @view_object.navigation_for :menu, :levels => 0..1
    result.should == ["<ul class=\"list\" id=\"menu\">",
                        "<li id=\"url1\">",
                          "<a href=\"url1\" id=\"url1\">",
                            "url1",
                          "</a>",
                          "<ul id=\"url1\">",
                            "<li id=\"suburl1\">",
                              "<a href=\"suburl1\" id=\"suburl1\">",
                                "suburl1",
                              "</a>",
                            "</li>",
                          "</ul>",
                        "</li>",
                        "<li id=\"url2\">",
                          "<a href=\"url2\" id=\"url2\">",
                            "url2",
                          "</a>",
                          "<ul id=\"url2\">",
                            "<li id=\"suburl2\">",
                              "<a href=\"suburl2\" id=\"suburl2\">",
                                "suburl2",
                              "</a>",
                            "</li>",
                          "</ul>",
                        "</li>",
                      "</ul>"].join  	
  end

  it 'should render navigation except some item' do
    @configuration.run do
      navigate :menu do
      	item :url1, 'url1', :name => 'url1' do
          item :suburl1, 'suburl1', :name => 'suburl1'
      	end
      	item :url2, 'url2', :name => 'url2' do
          item :suburl2, 'suburl2', :name => 'suburl2'
      	end
      end
    end

    result = @view_object.navigation_for :menu, :except_for => [:url1]
    result.should == ["<ul class=\"list\" id=\"menu\">",
                        "<li id=\"url2\">",
                          "<a href=\"url2\" id=\"url2\">",
                            "url2",
                          "</a>",
                          "<ul id=\"url2\">",
                            "<li id=\"suburl2\">",
                              "<a href=\"suburl2\" id=\"suburl2\">",
                                "suburl2",
                              "</a>",
                            "</li>",
                          "</ul>",
                        "</li>",
                      "</ul>"].join  	
  end

  it 'should render navigation except some items' do
    @configuration.run do
      navigate :menu do
      	item :url1, 'url1', :name => 'url1' do
          item :suburl1, 'suburl1', :name => 'suburl1'
      	end
      	item :url2, 'url2', :name => 'url2' do
          item :suburl2, 'suburl2', :name => 'suburl2'
      	end
      end
    end

    result = @view_object.navigation_for :menu, :except_for => [:suburl1,:url2]
    result.should == ["<ul class=\"list\" id=\"menu\">",
                        "<li id=\"url1\">",
                          "<a href=\"url1\" id=\"url1\">",
                            "url1",
                          "</a>",
                        "<ul id=\"url1\">",
                        "</ul>",
                        "</li>",
                      "</ul>"].join  	
  end  

end