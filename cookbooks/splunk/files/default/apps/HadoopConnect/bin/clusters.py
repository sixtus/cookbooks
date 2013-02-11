import os, os.path
from util import *
from constants import *

class Cluster:
    def __init__(self, name, props=None):
        self.name = name
        self.props = props
        self.hadoop_cli = None
        if name.startswith('hdfs://'):
            self.name = name[len('hdfs://'):]
        try:
            self.host, self.namenode_ipc_port = self.name.split(':')
            self.namenode_ipc_port = int(self.namenode_ipc_port)
        except:
            raise Exception('Namenode URI (clusters.conf stanza name) needs to be in host:port format and port must be a number, e.g. namenode.example.com:8020')
        if props:
            import splunk.util
            self.props['authorization_mode'] = 'true' if 'authorization_mode' in props and splunk.util.normalizeBoolean(props['authorization_mode']) else 'false'
            self.hadoop_cli = os.path.join(props['hadoop_home'], 'bin', 'hadoop') if 'hadoop_home' in props else None
    
    def validateHadoopVersion(self):
        if not os.path.exists(self.hadoop_cli):
            raise Exception('Could not find Hadoop cli in path="%s"' % str(self.hadoop_cli))
        
        # get local hadoop version
        local_version = self.getLocalHadoopVersion()
        remote_version = self.getRemoteHadoopVersion()
        # make sure local version is same as remote version
        if remote_version.find(local_version) < 0:
            raise Exception('Local Hadoop version does not match remote Hadoop version, local="%s", remote="%s"' % (local_version, remote_version))
    
    def getHadoopInfo(self):
        import hadooputils as hu
        return hu.getHadoopClusterInfo(self.host, int(self.props['namenode_http_port']))
        
    def getRemoteHadoopVersion(self):
        # get remote hadoop version
        info = self.getHadoopInfo()
        if not info or 'Version' not in info:
            raise Exception('Failed to get remote Hadoop cluster version, host="%s", port=%d' % (self.host, self.props['namenode_http_port']))
        remote_version = info['Version'].strip()
        return remote_version
    
    def openProcess(self, args, env):
        import subprocess
        return subprocess.Popen(args, shell=False, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env)
            
    def getLocalHadoopVersion(self):
        env = dict(os.environ)

        if self.props==None or 'hadoop_home' not in self.props:
            raise Exception('hadoop_home is not set!')
        env['HADOOP_HOME'] = self.props['hadoop_home'] 

        if self.props==None or 'java_home' not in self.props:
            raise Exception('java_home is not set!')
        env['JAVA_HOME'] = self.props['java_home']

        
        args = [self.hadoop_cli, 'version']
        process = self.openProcess(args, env)
        output = process.communicate()
        if process.returncode != 0:
            raise Exception('Could not determine local Hadoop version. Error while executing command="%s", error="%s"' % (' '.join(args), output[1]))
        local_version = output[0].split('\n')[0]
        local_version = local_version[len('Hadoop'):].strip()
        return local_version
            
    def save(self):
        dir = self.getClusterDir()
        if not os.path.isdir(dir):
            os.makedirs(dir)
        self.validateHadoopVersion()
        self.saveXml()
             
    def remove(self):
        dir = self.getClusterDir()
        if os.path.isdir(dir):
            import shutil
            shutil.rmtree(dir)

    def getClusterDir(self):
        return os.path.join(os.environ['SPLUNK_HOME'], 'etc', 'apps', APP_NAME, 'local', 'clusters', makeFileSystemSafe(self.name))
    
    def buildPropertyElement(self, configElement, name, value):
        from xml.etree.ElementTree import SubElement
        propertyElement = SubElement(configElement, 'property')
        nameElement = SubElement(propertyElement, 'name')
        nameElement.text = name
        valueElement = SubElement(propertyElement, 'value')
        valueElement.text = value
        
    def saveXml(self):
        from xml.etree import ElementTree
        from xml.etree.ElementTree import Element
        config = Element('configuration')
        self.buildPropertyElement(config, 'hadoop.security.authentication', self.props['authentication_mode'])
        self.buildPropertyElement(config, 'hadoop.security.authorization', self.props['authorization_mode'])
        if self.props['authentication_mode'] == 'kerberos':
            self.buildPropertyElement(config, 'dfs.namenode.kerberos.principal', self.props['kerberos_service_principal'])

        xmlfile = os.path.join(self.getClusterDir(), 'core-site.xml')
        tmpfile = xmlfile + '.tmp'
        xml = ElementTree.tostring(config, 'utf-8')
        with open(tmpfile, 'w') as f:
            f.write(xml)
        os.rename(tmpfile, xmlfile)

