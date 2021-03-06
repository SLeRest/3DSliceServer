import logging
import os
import requests 
from zipfile import ZipFile, ZipInfo
import os

# slerest 18/03/2021
# It's a hack for keeping permission on the unzipped file
class MyZipFile(ZipFile):
    def extract(self, member, path=None, pwd=None):
        if not isinstance(member, ZipInfo):
            member = self.getinfo(member)
        if path is None:
            path = os.getcwd()

        ret_val = self._extract_member(member, path, pwd)
        attr = member.external_attr >> 16
        os.chmod(ret_val, attr)
        return ret_val

def download_zip(url, save_path, chunk_size=128):
    r = requests.get(url, stream=True)
    with open(save_path, 'wb') as fd:
        for chunk in r.iter_content(chunk_size=chunk_size):
            fd.write(chunk)

def unzip(path, SLICER_SERVER_PATH):
    with MyZipFile(path, 'r') as zip_file:
        zip_file.extractall(SLICER_SERVER_PATH)

if __name__ == '__main__':
    FORMAT = '%(asctime)-15s %(levelname)s: %(message)s'
    DATEFMT = '%d/%m/%Y %H:%M:%S'
    FILENAME = 'slice_new_quotes.log'
    logging.basicConfig(format=FORMAT,
            level=logging.INFO,
            datefmt=DATEFMT)

    SLICER_SERVER_PATH = os.environ.get('3D_SLICER_SERVER_PATH', '/curaengine/4.8.0')
    logging.info('Start')

    # PROTOBUF 3.15.6
    # https://github.com/protocolbuffers/protobuf
    logging.info('Download and unzip Protobuf 3.15.6')
    url = 'https://github.com/protocolbuffers/protobuf/releases/download/v3.15.6/protobuf-all-3.15.6.zip'
    path = SLICER_SERVER_PATH + '/protobuf-all-3.15.6.zip'
    try:
        download_zip(url, path)
        unzip(path, SLICER_SERVER_PATH)
        # the .sh files for install doesn't have execute permission
        os.chmod(SLICER_SERVER_PATH + '/protobuf-3.15.6/autogen.sh', 0o755)
        os.chmod(SLICER_SERVER_PATH + '/protobuf-3.15.6/configure', 0o755)
    except Exception as e:
        logging.error('Download and unzip Protobuf 3.15.6: %s', str(e))
        raise e

    # LIBARCUS 4.8.0
    # https://github.com/Ultimaker/libArcus
    logging.info('Download and unzip libArcus 4.8.0')
    url = 'https://github.com/Ultimaker/libArcus/archive/4.8.0.zip'
    path = SLICER_SERVER_PATH + '/libArcus-4.8.0.zip'
    try:
        download_zip(url, path)
        unzip(path, SLICER_SERVER_PATH)
    except Exception as e:
        logging.error('Download and unzip libArcus 4.8.0: %s', str(e))
        raise e

    # CURAENGINE 4.8.0
    # https://github.com/Ultimaker/CuraEngine
    logging.info('Download and unzip Curaengine 4.8.0')
    url = 'https://github.com/Ultimaker/CuraEngine/archive/4.8.0.zip'
    path = SLICER_SERVER_PATH + '/curaengine-4.8.0.zip'
    try:
        download_zip(url, path)
        unzip(path, SLICER_SERVER_PATH)
    except Exception as e:
        logging.error('Download and unzip Curaengine 4.8.0: %s', str(e))
        raise e
