defmodule PhoenixblogWeb.PostLive.FormComponent do
  use PhoenixblogWeb, :live_component

  alias Phoenixblog.Blog

  alias Phoenixblog.Blog.Tag

  def tags_input(form) do
    tags_string =
      form
      |> input_value(:tags)
      |> Enum.map(&tag_to_string/1)
      |> Enum.join(", ")

    text_input(form, :tags, value: tags_string)
  end

  def tag_to_string(%Ecto.Changeset{} = tag) do
    Ecto.Changeset.get_field(tag, :name)
  end

  def tag_to_string(%Tag{} = tag) do
    tag.name
  end


  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Blog.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      socket.assigns.post
      |> Blog.change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    save_post(socket, socket.assigns.action, post_params)
  end

  defp save_post(socket, :edit, post_params) do
    case Blog.update_post(socket.assigns.post, post_params) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_post(socket, :new, post_params) do
    case Blog.create_post(post_params) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
