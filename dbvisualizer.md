## DbVisualizer Directory:

cd ~/dbvis_linux_25_1_4/opt/DbVisualizer

./dbvis

## Adding to PATH directory

1. Identify the full path to the dbvis executable:

e.g.:

/home/briean/dbvis_linux_25_1_4/opt/DbVisualizer

2. Add it to your PATH:


Open your ~/.bashrc file in a text editor:

nano ~/.bashrc

Add the following line to the end of the file:

export PATH="$PATH:/home/briean/dbvis_linux_25_1_4/opt/DbVisualizer"

Save the file and exit the editor.

To apply the changes without logging out and back in, "source" your ~/.bashrc file:

source ~/.bashrc
