require 'test_helper'

class VideosControllerTest < ActionDispatch::IntegrationTest
  describe "index" do
    it "returns a JSON array" do
      get videos_url
      assert_response :success
      expect(@response.headers['Content-Type']).must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      expect(data).must_be_kind_of Array
    end

    it "should return many video fields" do
      get videos_url
      assert_response :success

      data = JSON.parse @response.body
      data.each do |video|
        expect(video).must_include "title"
        expect(video).must_include "release_date"
      end
    end

    it "returns all videos when no query params are given" do
      get videos_url
      assert_response :success

      data = JSON.parse @response.body
      expect(data.length).must_equal Video.count

      expected_names = {}
      Video.all.each do |video|
        expected_names[video["title"]] = false
      end

      data.each do |video|
        expect(
          expected_names[video["title"]]
        ).must_equal false, "Got back duplicate video #{video["title"]}"

        expected_names[video["title"]] = true
      end
    end
  end

  describe "show" do
    it "Returns a JSON object" do
      get video_url(title: videos(:one).title)
      assert_response :success
      expect(@response.headers['Content-Type']).must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      expect(data).must_be_kind_of Hash
    end

    it "Returns expected fields" do
      get video_url(title: videos(:one).title)
      assert_response :success

      video = JSON.parse @response.body
      expect(video).must_include "title"
      expect(video).must_include "overview"
      expect(video).must_include "release_date"
      expect(video).must_include "inventory"
      expect(video).must_include "available_inventory"
    end

    it "Returns an error when the video doesn't exist" do
      get video_url(title: "does_not_exist")
      assert_response :not_found

      data = JSON.parse @response.body
      expect(data).must_include "errors"
      expect(data["errors"]).must_include "title"
    end
  end

    describe "create" do
      let(:video_hash) {
          {
          title: "Alf the movie",
          overview: "The most early 90s movie of all time",
          release_date: "December 16th 2025",
          inventory: 10,
          img_url: "http://google.com/images'",
          external_id: 123,
        }
      }

      it "creates a video" do
        expect {
          post videos_path, params: video_hash
        }.must_change 'Video.count', 1

        must_respond_with :success
      end
    end
end
