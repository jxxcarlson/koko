defmodule Koko.Latex.Parser do



  def transform_images(str) do
    imageScan(str)
      |> Enum.reduce str, (fn(image_match, acc) -> transform_image(image_match, acc) end)
  end

  def list_images(str) do
    imageScan(str)
      |> Enum.reduce [], (fn(image_match, acc) -> acc ++ [image_record(image_match)] end)
  end

  def image_link(image_record) do
    title = if image_record.title == "" do
              "UNTITLED"
            else
              image_record.title
            end
    "<div style=\"margin-bottom:30px; margin-right: 15px; display: inline-block\"><a href=\"http://#{image_record.url}\" download>
      <img border=\"0\" src=\"http://#{image_record.url}\" height=\"100\">
    </a>
    <p>#{title}</p></div>"
  end

  def image_links(str) do
    str
      |> list_images
      |> Enum.reduce "", (fn(item, acc) -> acc <> "\n#{image_link(item)}\n" end )
  end

  # String -> List String
  def image_url_list(str) do
    str
      |> list_images
      |> Enum.map(fn item -> "https://" <> item.url end)
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
    if (length item) == 2 do
      [key, value] = item
      Map.put(map, key, value)
    else
      map
    end
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

  def image_record(item) do
    [target, url, title, attribute_string] = item
    filename = url |> String.split("/") |> Enum.reverse |> hd
    %{ title: title, filename: filename, url: url}
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
    {width, _} = Integer.parse image.attributes["width"]
    "\\imagecenter{image/#{image.filename}}{#{image.title}}{#{6.0*width/700}in}"
  end

  def transform_text(text) do
    text 
      |> String.replace("#", "\\#")
      |> String.replace("\\backslash", "\\bs")
  end


end
