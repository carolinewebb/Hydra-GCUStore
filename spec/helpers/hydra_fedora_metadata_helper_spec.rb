require 'spec_helper'

describe HydraFedoraMetadataHelper do
  
  before(:all) do
    # @mock_ng_ds = mock("nokogiri datastream")
    # @mock_ng_ds.stubs(:kind_of?).with(ActiveFedora::NokogiriDatastream).returns(true)
    # @mock_ng_ds.stubs(:class).returns(ActiveFedora::NokogiriDatastream)
    # @mock_md_ds = stub(:stream_values=>"value")
    # datastreams = {"ng_ds"=>@mock_ng_ds,"simple_ds"=>@mock_md_ds}
    @resource = mock("fedora object")
    # @resource.stubs(:datastreams).returns(datastreams)
    # @resource.stubs(:datastreams_in_memory).returns(datastreams)
        
    @resource.stubs(:get_values_from_datastream).with("simple_ds", "subject", "").returns( ["topic1","topic2"] )

    @resource.stubs(:get_values_from_datastream).with("ng_ds", [:title, :main_title], "").returns( ["My Title"] )
    @resource.stubs(:get_values_from_datastream).with("ng_ds", [{:person=>1}, :given_name], "").returns( ["Bob"] )

    @resource.stubs(:get_values_from_datastream).with("empty_ds", "something", "").returns( [""] )
    @resource.stubs(:pid).returns("_PID_")
  end
  
  describe "fedora_text_field" do
    it "should generate a text field input with values from the given datastream" do
      generated_html = helper.fedora_text_field(@resource,"ng_ds",[:title, :main_title])
      generated_html.should be_html_safe
      generated_html.should have_selector "#title_main_title_0-container.editable-container" do
        with_tag "span#title_main_title_0-text.editable-text.text", "My Title"
        with_tag "input#title_main_title_0.editable-edit.edit" do
          with_tag "[value=?]", "My Title"
          with_tag "[name=?]","asset[ng_ds][title_main_title][0]"
          with_tag "[data-datastream-name=?]", "ng_ds" 
          with_tag "[rel=?]", "title_main_title"
        end
      end
    end
    it "should generate an ordered list of text field inputs" do
      generated_html = helper.fedora_text_field(@resource,"simple_ds","subject")
      generated_html.should have_selector "ol[rel=subject]" do
        with_tag "li#subject_0-container.editable-container.field" do
          without_tag "a.destructive.field"
          with_tag "span#subject_0-text.editable-text.text", "topic1"
          with_tag "input#subject_0.editable-edit.edit" do
            with_tag "[value=?]", "topic1"
            with_tag "[name=?]", "asset[simple_ds][subject][0]"
          end
        end
        with_tag "li#subject_1-container.editable-container.field" do
          with_tag "a.destructive.field"
          with_tag "span#subject_1-text.editable-text.text", "topic2"
          with_tag "input#subject_1.editable-edit.edit" do
            with_tag "[value=?]", "topic2"
            with_tag "[name=?]", "asset[simple_ds][subject][1]"
          end
        end
      end
      generated_html.should have_selector "input", :class=>"editable-edit", :id=>"subject_1", :name=>"asset[simple_ds][subject_1]", :value=>"topic9"                                                                                        
    end
    it "should render an empty control if the field has no values" do
      helper.fedora_text_field(@resource,"empty_ds","something").should have_selector "li#something_0-container.editable-container" do
        with_tag "#something_0-text.editable-text.text", ""
      end
    end
    it "should limit to single-value output with no ordered list if :multiple=>false" do
      generated_html = helper.fedora_text_field(@resource,"simple_ds","subject", :multiple=>false)
      generated_html.should_not have_selector "ol"
      generated_html.should_not have_selector "li"
      
      generated_html.should have_selector "span#subject-container.editable-container.field" do
        with_tag "span#subject-text.editable-text.text", "topic1"
        with_tag "input#subject.editable-edit.edit[value=topic1]" do
          with_tag "[name=?]", "asset[simple_ds][subject][0]"
        end
      end                                                                                                                                                                                                
    end
  end
  
  
  describe "fedora_select" do
    it "should generate a select with values from the given datastream" do
      generated_html = helper.fedora_select(@resource,"simple_ds","subject", :choices=>["topic1","topic2", "topic3"])
      generated_html.should have_selector "select.metadata-dd" do |input|
        input.should have_selector "[name=?]", "asset[simple_ds][subject][0]"
        with_tag "[rel=?]", "subject" 
        with_tag "option[value=topic1][selected=selected]"
        with_tag "option[value=topic2][selected=selected]"
        with_tag "option[value=topic3]"
      end
    end
    it "should return the product of fedora_text_field if :choices is not set" do
      helper.expects(:fedora_text_field).returns("fake response")
      generated_html = helper.fedora_select(@resource,"simple_ds","subject")
      generated_html.should == "fake response"
    end
  end

  describe "fedora_date_select" do
    it "should generate a date picker with values from the given datastream" do
      generated_html = helper.fedora_date_select(@resource,"simple_ds","subject")
      generated_html.should have_selector ".date-select" do |input|
        input.should have_selector "[name=?]", "asset[simple_ds][subject]"
        with_tag "[rel=?]", "subject" 
        with_tag "input#subject-sel-y.controlled-date-part.w4em"
        with_tag "select#subject-sel-mm.controlled-date-part" do
          with_tag "option[value=01]", "January"
          with_tag "option[value=12]", "December"
        end
        with_tag "select#subject-sel-dd.controlled-date-part" do
          with_tag "option[value=01]", "01"
          with_tag "option[value=31]", "31"
        end

      end
    end
  end
  
  describe "all field generators" do
    it "should include any necessary field_selector info" do
      field_selectors_regexp = helper.field_selectors_for("ng_ds",[:title, :main_title]).gsub('/','\/').gsub(']','\]').gsub('[','\[')
      ["fedora_text_field", "fedora_text_area", "fedora_select", "fedora_date_select"].each do |method|
        generated_html = eval("helper.#{method}(@resource,\"ng_ds\",[:title, :main_title])")
        generated_html.should match( field_selectors_regexp )
      end
      generated_html = helper.fedora_select(@resource,"ng_ds",[:title, :main_title], :choices=>["choice1"])
      generated_html.should match( field_selectors_regexp )
    end
  end
  
  describe "fedora_text_field_insert_link" do
    it "should generate a link for inserting a fedora_text_field into the page" do
      generated_html =helper.fedora_text_field_insert_link("ng_ds",[:title, :main_title])
      generated_html.should have_selector "a.addval.textfield" do
        input.should have_selector "[href=\#]"
      end
    end
  end
  
  describe "fedora_text_area_insert_link" do
    it "should generate a link for inserting a fedora_text_area into the page" do
      generated_html =helper.fedora_text_area_insert_link("ng_ds",[:title, :main_title])
      generated_html.should have_selector "a.addval.textarea" do 
        input.should have_selector "[href=\#]"
      end
    end
      
  end
  
  describe "fedora_field_label" do
    it "should generate a label with appropriate @for attribute" do
       generated_html = helper.fedora_field_label("ng_ds",[:title, :main_title], "Title:")
       generated_html.should have_selector "label[for=title_main_title]", :text=>"Title:"
    end 
    it "should display the field name if no label is provided" do
      helper.fedora_field_label("ng_ds",[:title, :main_title]).should have_selector "label[for=title_main_title]", :text=>"title_main_title"
    end
  end
  
  describe "field_selectors_for" do
    it "should generate any necessary field_selector values for the given field" do
      generated_html = helper.field_selectors_for("myDsName", [{:name => 3}, :name_part])
      generated_html.should have_selector "input.fieldselector[type=hidden]" do
        input.should have_selector "[name=?]", "field_selectors[myDsName][name_3_name_part][][name]"
        with_tag "[rel=name_3_name_part]"
        with_tag "[value=3]"
      end
      generated_html.should have_selector "input.fieldselector[type=hidden]" do
        input.should have_selector "[name=?]", "field_selectors[myDsName][name_3_name_part][]"
        with_tag "[rel=name_3_name_part]"
        with_tag "[value=name_part]"
      end
      # ordering is important.  this next line makes sure that the inputs are in the correct order
      # (tried using CSS3 nth-of-type selectors in have_tag but it didn't work)
      generated_html.should match(/<input.*name="field_selectors\[myDsName\]\[name_3_name_part\]\[\]\[name\]".*\/><input.*name="field_selectors\[myDsName\]\[name_3_name_part\]\[\].*value="name_part" .*\/>/)
    end
    it "should not generate any field selectors if the field key is not an array" do
      helper.field_selectors_for("myDsName", :description).should == ""
    end
  end

  describe "fedora_textile_text_area" do
    it "should be html safe" do
      generated_html = helper.fedora_textile_text_area(@resource,"ng_ds",[:title, :main_title])
      generated_html.should be_html_safe
      generated_html.should have_selector "input.fieldselector"
      generated_html.should have_selector "ol li.field_value"
    end
  end
  
end
