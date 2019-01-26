#! /usr/bin/env python
#
#   File = example-jpeg-to-xcf.py
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################

# The file selection/iteration part of the code is modified from a tutorial
# written by Stephen Kiel with the processing replaced by my own code.

# --Import relevant libraries--------------------------------------------------
from gimpfu import *
import os
import re

# --Define function------------------------------------------------------------
def batch_resize(srcPath, tgtPath, resOut, square, overwrite):
    """Registered function batch_resize, Resizes all files from the source
    folder, putting the results in the target folder. Additionally, can be
    specified to add white pixels to make the image square. Can be set to
    overwrite or avoid existing files.
    """

    # --If safe to go ahead, list all the files in both folders--------------------
    if pdb.gimp_image_list()[0] > 0:
        pdb.gimp_message("Close open Images & Rerun")
    else:
        allFileList = os.listdir(srcPath)
        existingList = os.listdir(tgtPath)
        srcFileList = []
        tgtFileList = []
        xform = re.compile("\.jpg", re.IGNORECASE)

        # --Only pulls in jpg files, also generates output names here------------------
        for fname in allFileList:
            fnameLow = fname.lower()
            # Keeping file extension assignment in to keep same file extensions
            if fnameLow.count(".jpg") > 0:
                srcFileList.append(fname)
                tgtFileList.append(xform.sub(".jpg", fname))
        tgtFileDict = dict(zip(srcFileList, tgtFileList))

        # --Cycle through, opening and resizing files----------------------------------
        for srcFile in srcFileList:
            if (tgtFileDict[srcFile] not in existingList) or overwrite:
                # os.path.join inserts the right kind of file separator
                tgtFile = os.path.join(tgtPath, tgtFileDict[srcFile])
                srcFile = os.path.join(srcPath, srcFile)
                imageIn = pdb.file_jpeg_load(srcFile, srcFile)
                # Finds the correct sizes for both dimensions of the image.
                res = (pdb.gimp_image_width(imageIn), pdb.gimp_image_height(imageIn))
                xScal, yScal = (float(resOut) / res[0], float(resOut) / res[1])
                xScal, yScal = (
                    int(min(xScal, yScal) * res[0]),
                    int(min(xScal, yScal) * res[1]),
                )

                pdb.gimp_image_scale(imageIn, xScal, yScal)
                # --Reshape the image to a square if requested---------------------------------
                if square:
                    addTo = [max(yScal - xScal, 0), max(xScal - yScal, 0)]
                    pdb.gimp_image_resize(
                        imageIn,
                        addTo[0] + xScal,
                        addTo[1] + yScal,
                        addTo[0] / 2,
                        addTo[1] / 2,
                    )
                    pdb.gimp_layer_resize(
                        pdb.gimp_image_get_active_layer(imageIn),
                        addTo[0] + xScal,
                        addTo[1] + yScal,
                        addTo[0] / 2,
                        addTo[1] / 2,
                    )
                # --Save to disk & close-------------------------------------------------------
                drawableOut = imageIn.active_drawable

                pdb.file_jpeg_save(
                    imageIn,
                    drawableOut,
                    tgtFile,
                    tgtFile,
                    0.8,
                    0,
                    1,
                    1,
                    "Automatically re-sized output.",
                    0,
                    1,
                    0,
                    0,
                )

                pdb.gimp_image_delete(imageIn)


# --Register the script--------------------------------------------------------
register(
    "batch_resize",
    "Resize all images in the input folder and save them to the output",
    "Batch resize.",
    "Joe McGrath",
    "Joe McGrath",
    "March 2015",
    "Batch resize",
    "",
    [
        (PF_DIRNAME, "srcPath", "Input path:", "C:\\"),
        (PF_DIRNAME, "tgtPath", "Output path:", "C:\\"),
        (PF_INT32, "resOut", "Long-side resolution:", "150"),
        (PF_BOOL, "square", "Format to square:", True),
        (PF_BOOL, "overwrite", "Overwrite existing files:", False),
    ],
    [],
    batch_resize,  # Matches to name of function being defined
    menu="<Image>/Batch processing",  # Menu Location
)  # End register

main()
