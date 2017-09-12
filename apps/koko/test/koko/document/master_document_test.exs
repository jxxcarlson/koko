defmodule Koko.MasterDocumentTest do
  use Koko.DataCase

  alias Koko.Document.MasterDocument
  alias Koko.Document.Document
  alias Koko.Repo
  alias Koko.Document.Query


  test "is_master finds master documents" do
    n = Document |> Query.is_master |> Repo.all |> length
    assert n > 0
  end

  @content_A """
THIS IS MASTER
++ Table of Contents
== 21 Painting // Yada yada!
== 22 Child B // comment

  """

  @child_A %Koko.Document.Document{
     attributes: %{"doc_type" => "standard", "level" => 2, "public" => true,
       "text_type" => "adoc"}, author_id: 1, author_name: "jxxcarlson",
     children: [],
     content: "CHILD A",
     id: 21, identifier: "jxxcarlson.child_a.2017-8-22@2-26-12.67dceb",
     parent_id: 365,
     rendered_content: "CHILD A",
     title: "Child A"
   }

   @child_B %Koko.Document.Document{
      attributes: %{"doc_type" => "standard", "level" => 2, "public" => true,
        "text_type" => "adoc"}, author_id: 1, author_name: "jxxcarlson",
      children: [],
      content: "CHILD B",
      id: 22, identifier: "jxxcarlson.child_a.2017-8-22@2-26-12.67dceb",
      parent_id: 0,
      rendered_content: "CHILD B",
      title: "Child B"
    }

  @master %Koko.Document.Document{
     attributes: %{"doc_type" => "master", "level" => 0, "public" => true,
       "text_type" => "adoc"}, author_id: 1, author_name: "jxxcarlson",
     children: [%Child{comment: "Yada yada!", doc_id: 21,
       doc_identifier: "jxxcarlson.child_a.2017-8-22@2-26-12.67dceb", level: 2,
       title: "Painting"}],
     content: "THIS IS MASTER",
     id: 365,
     identifier: "jxxcarlson.visual_literacy.2017-8-31@3-59-7.dffcbb",
     parent_id: 0,
     rendered_content: "THIS IS MASTER",
     title: "Master"
  }

  def setup_children do
    Repo.insert!(@child_A)
    Repo.insert!(@child_B)
  end

  describe "Initial data" do

    test "Master document is valid" do
      master = @master
      assert master.title == "Master"
      assert master.children |> length == 1
      assert master.attributes["doc_type"] == "master"
    end

    test "Child document is valid" do
      master = @master
      child = @child_A
      assert child.parent_id == master.id
      assert child.attributes["doc_type"] == "standard"
    end

  end


  describe "Generation of table of contents" do

    test "toc from children" do
      master = @master
      expected_toc = "== 21 Painting // Yada yada!\n"
      assert expected_toc == MasterDocument.toc_from_children(master.children)
    end

    test "Generation of updated content for master from children" do
      # Note that the data in `chidren` takes precedence over the
      # data in the "above the line" text.
      master = @master
      updated_content = MasterDocument.updated_text_from_children(master.content, master.children)
      expected_content = """
  THIS IS MASTER
  ++ Table of Contents
  == 21 Painting // Yada yada!
  """
      assert updated_content == expected_content

    end

  end

  describe "attach document" do

    test "attach document above" do
      master = @master
      child = Repo.insert!(@child_A)
      new_child = Repo.insert!(@child_B)
      position = "above"
      remaining_commands = [["child", "#{new_child.id}"], ["current", "#{child.id}"]]

      [_, updated_text] = MasterDocument.attach(master, position, remaining_commands)
      expected_text = """
THIS IS MASTER
++ Table of Contents
== 22 Child B // comment
== 21 Painting // Yada yada!
"""
      assert expected_text == updated_text
      new_child = Repo.get(Document, new_child.id)
      assert new_child.parent_id == master.id
    end

    test "attach document below" do
      master = @master
      child = Repo.insert!(@child_A)
      new_child = Repo.insert!(@child_B)
      position = "below"
      remaining_commands = [["child", "#{new_child.id}"], ["current", "#{child.id}"]]

      [_, updated_text] = MasterDocument.attach(master, position, remaining_commands)
      expected_text = """
  THIS IS MASTER
  ++ Table of Contents
  == 21 Painting // Yada yada!
  == 22 Child B // comment
  """
      assert expected_text == updated_text
      new_child = Repo.get(Document, new_child.id)
      assert new_child.parent_id == master.id
    end

    test "attach document at top" do
      master = @master
      Repo.insert!(@child_A)
      new_child = Repo.insert!(@child_B)
      position = "at-top"
      remaining_commands = [["child", "#{new_child.id}"]]

      [_, updated_text] = MasterDocument.attach(master, position, remaining_commands)
      expected_text = """
THIS IS MASTER
++ Table of Contents
== 22 Child B // comment
== 21 Painting // Yada yada!
"""
      assert expected_text == updated_text
      new_child = Repo.get(Document, new_child.id)
      assert new_child.parent_id == master.id

    end

    test "attach document at bottom" do
      master = @master
      Repo.insert!(@child_A)
      new_child = Repo.insert!(@child_B)
      position = "at-bottom"
      remaining_commands = [["child", "#{new_child.id}"]]

      [_, updated_text] = MasterDocument.attach(master, position, remaining_commands)
      expected_text = """
THIS IS MASTER
++ Table of Contents
== 21 Painting // Yada yada!
== 22 Child B // comment
"""
      assert expected_text == updated_text
      new_child = Repo.get(Document, new_child.id)
      assert new_child.parent_id == master.id
    end

#     test "attach document above" do
#       master = @master
#       child = Repo.insert!(@child_A)
#       new_child = Repo.insert!(@child_B)
#       position = "above"
#       remaining_commands = [["child", "#{new_child.id}"], ["current", "#{child.id}"]]
#
#       [_, updated_text] = MasterDocument.attach(master, position, remaining_commands)
#       expected_text = """
# THIS IS MASTER
# ++ Table of Contents
# == 22 Child B // comment
# == 21 Painting // Yada yada!
# """
#       assert expected_text == updated_text
#       new_child = Repo.get(Document, new_child.id)
#       assert new_child.parent_id == master.id
#     end

  end ## describe attach document

  describe "Text parser" do

    test "parse_string" do
      setup_children()

      content = @content_A
      expected_parsed_content = [
        {:item, 1,
          %Child{comment: "Yada yada!", doc_id: 21,
           doc_identifier: "jxxcarlson.child_a.2017-8-22@2-26-12.67dceb", level: 2,
           title: "Child A"}},
        {:item, 2,
          %Child{comment: "comment", doc_id: 22,
           doc_identifier: "jxxcarlson.child_a.2017-8-22@2-26-12.67dceb", level: 2,
           title: "Child B"}},
        {:blank, 3, ""},
        {:blank, 4, ""}
      ]

      parsed_content = MasterDocument.parse_string content
      assert parsed_content == expected_parsed_content
    end

    test "parse_line" do
      setup_children()
      item = {"== 21 Painting", 1}

      expected_child =  %Child{
        comment: "", doc_id: 21,
        doc_identifier: "jxxcarlson.child_a.2017-8-22@2-26-12.67dceb",
        level: 2,
        title: "Child A"
      }
      expected_item = {:item, 1, expected_child}

      parsed_item = MasterDocument.parse_line item
      assert expected_item == parsed_item
    end

  end

  describe "foo" do


    test "set_children_from_content, updating comments & ignoring titles in content" do
      master = @master
      setup_children()
      new_content = """
THIS IS MASTER
++ Table of Contents
== 21 Oil Painting // Alpha
=== 22 Acrylic Painting // Beta
"""

     expected_children = [
          %Child{
              comment: "Alpha", doc_id: 21,
              doc_identifier: "jxxcarlson.child_a.2017-8-22@2-26-12.67dceb",
              level: 2,
              title: "Child A"},
          %Child{
            comment: "Beta",
            doc_id: 22,
            doc_identifier: "jxxcarlson.child_a.2017-8-22@2-26-12.67dceb",
            level: 3,
            title: "Child B"},
      ]
      changeset = Document.changeset(master, %{})
      {children, changeset} = MasterDocument.set_children_from_content changeset, master, new_content
      IO.inspect changeset, label: "XX, CHANGESET"
      assert children == expected_children
    end

  end



end
