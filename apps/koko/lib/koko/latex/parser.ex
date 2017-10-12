defmodule Koko.Latex.Parser do



  def transform_images(str) do
    imageScan(str)
      |> Enum.reduce str, (fn(image_match, acc) -> transform_image(image_match, acc) end)
  end

  def transform_image(image_match, str) do
    parsed_image = parse_image image_match
    rendered_image = render_image parsed_image
    target = parsed_image.target
    String.replace str, target, rendered_image
  end

  def imageScan(str) do
    rx = ~r/\\image\{http.*?\/\/(.*?)\}\{(.*?)\}\{(.*?)\}/
    Regex.scan rx, str
  end

  defp parseAttributes1(str) do
    str  |> (String.split ",") |> Enum.map (fn x -> (x |> String.trim) end)
         # |> Enum.map (fn(item) -> Parser.parseAttribute(item)end)
  end

  def parseAttributes(str) do
    str |> parseAttributes1 |> Enum.map (fn(item) -> parseAttribute(item)end)
  end


  def parseAttribute(attr) do
    attr |> String.split(":") |> Enum.map (fn item -> String.trim(item) end)
  end

  def filename(url) do
    url |> String.split("/") |> Enum.reverse |> hd
  end

  def add_kv(item, map) do
    [key, value] = item
    Map.put(map, key, value)
  end

  def make_map(list) do
    list |> Enum.reduce %{}, (fn(item, acc) -> add_kv(item, acc) end)
  end

  def parse_image(item) do
     [target, url, title, attribute_string] = item
     filename = url |> String.split("/") |> Enum.reverse |> hd
     attribute_list = parseAttributes attribute_string
     attributes = make_map attribute_list
     %{target: target, title: title, filename: filename, url: url, attributes: attributes}
  end

  def render_image(image) do
    case image.attributes["float"] do
      "left" -> left_float_image(image)
      "right" -> right_float_image(image)
      _ -> centered_image(image)
    end
  end

  def left_float_image(image) do
    width = image.attributes["width"]
    "\\imagefloatleft{image/#{image.filename}}{#{image.title}}{#{width}px}"
  end

  def  right_float_image(image) do
    width = image.attributes["width"]
    "\\imagefloatright{image/#{image.filename}}{#{image.title}}{#{width}px}"
  end

  def  centered_image(image) do
    width = image.attributes["width"]
    "\\imagecenter{image/#{image.filename}}{#{image.title}}{#{width}px}"
  end


end
