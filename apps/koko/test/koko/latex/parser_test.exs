defmodule Koko.LatesParserTest do
  use Koko.DataCase

  alias Koko.Latex.Parser


   @test_string """
   \\image{http://noteimages/foo/three_circles.png}{3 circles}{width: 90, float: right} foo, bar
   \\image{http://noteimages/foo/four_circles.png}{4 circles}{width: 90, float: right}
   """

   @expected_output """
   \\imagefloatright{image/three_circles.png}{3 circles}{90px} foo, bar
   \\image{http://noteimages/foo/four_circles.png}{4 circles}{width: 90, float: right}
   """

   @expected_output2 """
   \\imagefloatright{image/three_circles.png}{3 circles}{90px} foo, bar
   \\imagefloatright{image/four_circles.png}{4 circles}{90px}
   """

   test "test_string" do
      assert (String.length @test_string) == 176
   end


    test "imageScan recognizes two strings" do
       pp = Parser.imageScan @test_string
       assert (Enum.count pp) == 2
    end

    test "can unpack data from imageScan" do
      pp = (Parser.imageScan @test_string)
      qq = hd pp
      assert (length qq) == 4
      [target, url, title, attributes] = qq
      assert target == "\\image{http://noteimages/foo/three_circles.png}{3 circles}{width: 90, float: right}"
      assert url == "noteimages/foo/three_circles.png"
      assert title == "3 circles"
      assert attributes == "width: 90, float: right"
      assert Parser.filename(url) == "three_circles.png"
    end

    test "can parse attributes" do
      [target, url, title, attributes] = (Parser.imageScan @test_string) |> hd
      assert Parser.parseAttributes(attributes) == [["width", "90"], ["float", "right"]]
    end

    test "add_kv" do
      m = Parser.add_kv(["foo", "bar"], %{})
      assert m["foo"] == "bar"
    end

    test "add key-value pairs" do
      list = [["foo", "one"], ["bar", "two"], ["baz", "three"]]
      map = Parser.make_map list
      assert map["foo"] == "one"
      assert map["bar"] == "two"
      assert map["baz"] == "three"
    end

    test "parse image" do
      imageData = hd (Parser.imageScan @test_string)
      pi = Parser.parse_image(imageData)
      assert pi.title == "3 circles"
      assert pi.filename == "three_circles.png"
      assert pi.url == "noteimages/foo/three_circles.png"
      assert pi.attributes["width"] == "90"
      assert pi.attributes["float"] == "right"
      assert pi.attributes["align"] == nil
    end

    test "render image" do
      imageData = hd (Parser.imageScan @test_string)
      image = Parser.parse_image(imageData)
      ri = Parser.render_image(image)
      assert ri == "\\imagefloatright{image/three_circles.png}{3 circles}{90px}"
    end

    test "transform image" do
      imageData = hd (Parser.imageScan @test_string)
      output = Parser.transform_image(imageData, @test_string)
      assert output == @expected_output
    end

    test "transform images" do
      output = Parser.transform_images(@test_string)
      assert output == @expected_output2
    end



end
