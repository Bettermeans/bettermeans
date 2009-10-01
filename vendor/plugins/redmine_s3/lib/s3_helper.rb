require 'S3'
require 'rexml/document' # for ACL Document manipulation

module S3Helper

include REXML

  # returns public URL for key
  def public_link(bucket_name, key='')
    url = File.join('http://', S3::DEFAULT_HOST, bucket_name, key)
    str = link_to(key, url)
    str
  end
  
  # sets an ACL to public-read
  def self.set_acl_public_read(acl_doc)
        # create Document
        doc = Document.new(acl_doc)
  
        # get AccessControlList node
        acl_node = XPath.first(doc, '//AccessControlList')
  
        # delete existing 'AllUsers' Grantee
        acl_node.delete_element "//Grant[descendant::URI[text()='http://acs.amazonaws.com/groups/global/AllUsers']]"
  
        # create a new READ grant node
        grant_node = Element.new('Grant')
        grantee = Element.new('Grantee')
        grantee.attributes['xmlns:xsi'] = 'http://www.w3.org/2001/XMLSchema-instance'
        grantee.attributes['xsi:type'] = 'Group'
  
        uri = Element.new('URI')
        uri << Text.new('http://acs.amazonaws.com/groups/global/AllUsers')
        grantee.add_element(uri)
        grant_node.add_element(grantee)
        
        perm = Element.new('Permission')
        perm << Text.new('READ')
        grant_node.add_element(perm)
  
        # attach the new READ grant node
        acl_node.add_element(grant_node)
  
        return doc.to_s
  end

  # sets an ACL to private
  def self.set_acl_private(acl_doc)
        # create Document
        doc = Document.new(acl_doc)
  
        # get AccessControlList node
        acl_node = XPath.first(doc, '//AccessControlList')
  
        # delete existing 'AllUsers' Grantee
        acl_node.delete_element "//Grant[descendant::URI[text()='http://acs.amazonaws.com/groups/global/AllUsers']]"
  
        return doc.to_s
  end

  # sets an ACL to public-read-write
  def self.set_acl_public_read_write(acl_doc)
        # create Document
        doc = Document.new(acl_doc)
  
        # get AccessControlList node
        acl_node = XPath.first(doc, '//AccessControlList')
  
        # delete existing 'AllUsers' Grantee
        acl_node.delete_element "//Grant[descendant::URI[text()='http://acs.amazonaws.com/groups/global/AllUsers']]"
  
        # create a new READ grant node
        grant_node = Element.new('Grant')
        grantee = Element.new('Grantee')
        grantee.attributes['xmlns:xsi'] = 'http://www.w3.org/2001/XMLSchema-instance'
        grantee.attributes['xsi:type'] = 'Group'
  
        uri = Element.new('URI')
        uri << Text.new('http://acs.amazonaws.com/groups/global/AllUsers')
        grantee.add_element(uri)
        grant_node.add_element(grantee)
        
        perm = Element.new('Permission')
        perm << Text.new('READ')
        grant_node.add_element(perm)
  
        # attach the new grant node
        acl_node.add_element(grant_node)
  
        # create a new WRITE grant node
        grant_node = Element.new('Grant')
        grantee = Element.new('Grantee')
        grantee.attributes['xmlns:xsi'] = 'http://www.w3.org/2001/XMLSchema-instance'
        grantee.attributes['xsi:type'] = 'Group'
  
        uri = Element.new('URI')
        uri << Text.new('http://acs.amazonaws.com/groups/global/AllUsers')
        grantee.add_element(uri)
        grant_node.add_element(grantee)
        
        perm = Element.new('Permission')
        perm << Text.new('WRITE')
        grant_node.add_element(perm)
  
        # attach the new grant tree
        acl_node.add_element(grant_node)
  
        return doc.to_s
  end
  
end
