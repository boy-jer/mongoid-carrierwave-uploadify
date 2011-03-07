require 'spec_helper'
require 'remarkable/mongoid'

# Don't test carrierwave itself. It has a great test suite.
# Test only that carrierwave is attached and working plus
# any extras we add -- like saving dimensions.

describe Photo do
  before { @story = Fabricate(:story) }

  # Remarkable/mongoid macro
  it { should be_embedded_in(:story) }

  describe ".image" do
    before { stub_magick }

    it "should fail when no file is assigned" do
      @photo = @story.photos.build
      @photo.save.should be_false
    end

    # This should be enough to test that carrierwave is working
    it "should succeed when file is assigned" do
      @photo = @story.photos.create :image_filename => "test.jpg"
      @photo.image.current_path.should == (Rails.public_path + "/uploads/photo/image/#{@photo.id}/test.jpg")
    end
  end

  describe ".image dimensions" do
    before do
      stub_magick(640, 480)
      @photo = @story.photos.create :image_filename => "test.jpg"
    end

    it "should save height" do
      @photo.height.should == 480
    end

    it "should save width" do
      @photo.width.should == 640
    end
  end

  describe ".image orientation" do
    it "should save as landscape" do
      stub_magick(640, 480)
      @photo = @story.photos.create :image_filename => "test.jpg"
      @photo.orientation.should == "landscape"
    end

    it "should save as portrait" do
      stub_magick(480, 640)
      @photo = @story.photos.create :image_filename => "test.jpg"
      @photo.orientation.should == "portrait"
    end
  end

  describe "position" do
    before do
      stub_magick
      @photo1 = @story.photos.create :image_filename => "image1.jpg"
      @photo2 = @story.photos.create :image_filename => "image2.jpg"
      @photo3 = @story.photos.create :image_filename => "image3.jpg"
    end

    it "should set position" do
      @photo1.position.should == 1
      @photo2.position.should == 2
      @photo3.position.should == 3
    end
  end

  private

    def stub_magick(width=1280, height=960)
      MiniMagick::Image.stub!(:open).and_return(:width => width, :height => height)
    end

end
