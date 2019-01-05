defmodule Koko.Web.DocumentView do
  use Koko.Web, :view
  alias Koko.Web.DocumentView
  alias Koko.Document.Document

  def render("index.json", %{documents: documents}) do
    %{documents: render_many(documents, DocumentView, "document.json")}
  end

  def render("indexV2.json", %{documents: documents}) do
    %{documents: render_many(documents, DocumentView, "documentV2.json")}
  end

  def render("index_loading.json", %{documents: documents}) do
    %{documents: render_many(documents, DocumentView, "document_loading.json")}
  end

  def render("show.json", %{document: document}) do
    %{document: render_one(document, DocumentView, "document.json")}
  end

  def render("documentRecordV2.json", %{document: document}) do
    document_view = render("documentV2.json", %{document: document})
    %{document: document_view}
  end


  def render("documentV2.json", %{document: document}) do
    %{id: document.id,
      identifier: document.identifier,
      authorId: document.author_id,
      authorIdentifier: "NOT YET IMPLEMENTED",
      authorName: document.author_name || ""  ,
      title: document.title,
      content:  document.content,
      sectionNumber:  document.section_number || 1,
      texMacroDocumentId:  document.tex_macro_document_id || 0,
      level: document.attributes["level"] || 0,
      public: document.attributes["public"] || false,
      access: document.access || %{},
      tags: document.tags,
      children: document.children,
      parentId: document.parent_id || 0,
      parentTitle: Document.parent_title(document),
      textType: document.attributes["text_type"] || "plain",
      docType: document.attributes["doc_type"] || "standard",
      archive: document.attributes["archive"] || "default",
      version: document.attributes["version"] || 0,
      lastViewed: document.viewed_at |> ensureNonNilDate |> Calendar.NaiveDateTime.to_date_time_utc |> Calendar.DateTime.Format.unix,
      created: document.inserted_at |> Calendar.NaiveDateTime.to_date_time_utc |> Calendar.DateTime.Format.unix,
      lastModified: document.updated_at |> Calendar.NaiveDateTime.to_date_time_utc |> Calendar.DateTime.Format.unix
    }
  end

   # document.viewed_at |> DateTime.to_unix(:milliseconds),

   def ensureNonNilDate(arg) do
      if is_nil arg do
        ~N[2018-01-01 10:49:04.321812]
      else
         arg
      end
   end

  def to_posix_null{datetime} do
    IO.inspect(datetime, label: "dt")
    0
  end


  def to_posix{datetime} do
    {{y, mo, d}, {h, m, s, ms}} = datetime
    31557600*y + 2592000*mo + d*86400
  end

  def to_posix1(date_time) do
      0
  end

  # IO.inspect date_time, label: "date_timeXYZ"
  # if date_time == nil do
  #   0
  # else
  #   DateTime.to_unix(date_time)*1000

  def to_posix2(naive_date_time) do
    with {:ok, dt} =  DateTime.from_naive(naive_date_time, "Etc/UTC")
    do
     dt |> DateTime.to_unix(:milliseconds)
    else
      error -> 0
    end
  end



  def render("document.json", %{document: document}) do
    %{id: document.id,
      identifier: document.identifier,
      author_id: document.author_id,
      author_name: document.author_name || "",
      access: document.access || %{},
      title: document.title,
      content:  document.content,
      rendered_content:  document.rendered_content,
      attributes: document.attributes,
      tags: document.tags,
      children: document.children,
      parent_id: document.parent_id || 0,
      parent_title: Document.parent_title(document)
    }
  end

  def render("document_loading.json", %{document: document}) do
    %{id: document.id,
      identifier: document.identifier,
      author_id: document.author_id,
      author_name: document.author_name,
      access: document.access || %{},
      title: document.title,
      content: "Loading ...", #document.content,
      rendered_content: "Loading ...", #document.rendered_content,
      attributes: document.attributes,
      tags: document.tags,
      children: document.children,
      parent_id: document.parent_id || 0,
      parent_title: Document.parent_title(document)
    }
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end

  def render("reply.json", %{reply: reply}) do
    %{reply: reply}
  end

end
