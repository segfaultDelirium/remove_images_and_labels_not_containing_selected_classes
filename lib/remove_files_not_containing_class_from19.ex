defmodule RemoveFilesNotContainingClassFrom19 do
  @moduledoc """
  Documentation for `RemoveFilesNotContainingClassFrom19`.
  Program will read files with labels and if 
  the label file does not contain one of the 19 selected classes then that label file along with the image will be removed.
  """

  @doc """
  Hello world.
  COCO            - VOC               - Objects365
  0: person       - 14: person        - 0: Person
  1: bicycle      - 1: bicycle        - 46: Bicycle
  2: car          - 6: car            - 5: Car
  3: motorcycle   - 13: motorbike     - 58: Motorcycle
  4: airplane     - 0: aeroplane      - 114: Airplane
  5: bus          - 5: bus -          - 55: Bus
  6: train        - 18: train         - 116: Train
  8: boat         - 3: boat           - 21: Boat
  14: bird        - 2: bird           - 56: Wild Bird
  15: cat         - 7: cat            - 139: Cat
  16: dog         - 11: dog           - 92: Dog
  17: horse       - 12: horse         - 78: Horse
  19: cow         - 9: cow            - 96: Cow
  39: bottle      - 4: bottle         - 8: Bottle
  56: chair       - 8: chair          - 2: Chair
  57: couch       - 17: sofa          - 50: Couch
  58: potted plant- 15: pottedplant   - 25: Potted Plant
  60: dining table- 10: diningtable   - 98: Dinning Table
  18: sheep       - 16: sheep         - 99: Sheep
  62: tv          - 19: tvmonitor     - 37: Monitor/TV


  ## Examples

      iex> RemoveFilesNotContainingClassFrom19.hello()
      :world

  """
  def hello do
    :world
  end

  def main() do
    classes19 = [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "8",
      "14",
      "15",
      "16",
      "17",
      "19",
      "39",
      "56",
      "57",
      "58",
      "60",
      "18",
      "62"
    ]

    classes19 |> Enum.each(&IO.puts(&1))

    train_label_filenames = Path.wildcard("labels/train2017/*.txt") |> remove_label_files_which_corresponde_to_no_image()

    val_label_filenames = Path.wildcard("labels/val2017/*.txt") |> remove_label_files_which_corresponde_to_no_image()

    copy_valid_images_and_labels_to_output(val_label_filenames, classes19)
    copy_valid_images_and_labels_to_output(train_label_filenames, classes19)
  end

  def remove_label_files_which_corresponde_to_no_image(label_filenames) do
    label_filenames |> Enum.filter(fn label_filename -> 
      label_filename |> convert_label_filename_to_image_filename() |> File.exists?
    end) 
  end

  def copy_valid_images_and_labels_to_output(label_filenames, classes19) do
    valid_label_filenames = get_list_of_valid_label_filenames(label_filenames, classes19)
    valid_label_filenames |> copy_valid_files_to_output_dir

    valid_image_filenames =
      valid_label_filenames
      |> Enum.map(fn label_filename ->
        convert_label_filename_to_image_filename(label_filename)
      end)

    valid_image_filenames |> copy_valid_files_to_output_dir
  end

  def copy_valid_files_to_output_dir(filenames) do
    filenames
    |> Enum.map(fn filename ->
      output_filename =
        filename |> prepend_output_dir_to_filename |> prepend_dot_slash_to_filename

      input_filename = filename |> prepend_dot_slash_to_filename
      File.cp(input_filename, output_filename)
    end)
  end

  def prepend_output_dir_to_filename(filename) do
    "output/" <> filename
  end

  def prepend_dot_slash_to_filename(filename) do
    "./" <> filename
  end

  def convert_label_filename_to_image_filename(label_filename) do
    label_filename
    |> String.split(".")
    |> List.first()
    |> (&(&1 <> ".jpg")).()
    |> String.replace("labels", "images")
  end

  def get_list_of_valid_label_filenames(label_filenames, classes19) do
    label_filenames
    |> Enum.filter(fn filename ->
      File.read!(filename) |> is_file_valid?(classes19)
    end)
  end

  # file should stay if at least one line contains a class from classes19
  def is_file_valid?(label_file_content, classes19) do
    # IO.puts(label_file_content)
    lines = label_file_content |> String.split("\n", trim: true)
    lines |> Enum.any?(fn line -> does_line_contain_1_of_19?(line, classes19) end)
  end

  def does_line_contain_1_of_19?(line, classes19) do
    class_in_that_line = line |> String.split() |> List.first()
    # Enum.find returns nil if the list does not include class_in_that_line
    classes19 |> Enum.find(&(&1 == class_in_that_line)) != nil
  end
end
