####################################################################
#  Perl interface to CommuniGate Pro CLI.
#
#  Version 2.6.4
#
#  Original location: <http://www.stalker.com/CGPerl>
#  Revision history: <http://www.stalker.com/CGPerl/History.html>
#
#  See <http://www.stalker.com/CommuniGatePro/CLI.html> for the related info.
#
#  Mail your comments and error reports to <support@stalker.com>

############################## Commands: 
# new
# Logout
# getErrCode
# getErrMessage
# isSuccess
# getErrCommand
# setStringsTranslateMode
# NewPassword
# SendCommand
# GetResponseData

############################## Accounts commands
# ListAccounts
# CreateAccount 
# RenameAccount 
# DeleteAccount
# GetAccountSettings
# GetAccountEffectiveSettings
# UpdateAccountSettings
# SetAccountSettings
# SetAccountPassword
# VerifyAccountPassword
# GetAccountAliases
# SetAccountAliases
# GetAccountRules
# SetAccountRules
# GetAccountRPOP
# SetAccountRPOP
# GetAccountRights
# SetAccountRights
# GetAccountInfo
# GetWebUser
# SetWebUser
# GetEffectiveWebUser

############################## Group Commands
# ListGroups
# CreateGroup
# RenameGroup
# DeleteGroup
# GetGroup
# SetGroup

############################## Forwarder Commands
# ListForwarders
# CreateFrowarder
# DeleteForwarder
# GetForwarder

############################## Domain commands
# ListDomains
# MainDomainName
# [Get|Update|Set]DomainSettings
# GetDomainEffectiveSettings
# [Create|Rename|Delete]Domain
# CreateSharedDomain
# CreateDirectoryDomain
# [Get|Set]DomainRules
# [Get|Set]DomainAliases
# ListAdminDomains
# [Insert|Delete]DirectoryRecords
# [Get|Set]DirectoryIntegration
# [Get|Set]ClusterDirectoryIntegration


# [Get|Update|Set]DomainDefaults
# [Get|Update|Set]ClusterDomainDefaults
# [Get|Update|Set]AllAccountsDefaults
# GetAccountLocation
# [Get|Update|Set]AccountDefaults
# [Get|Update|Set]ClusterAccountDefaults
# [Get|Set]WebUserDefaults
# [Get|Set]ServerWebUserDefaults
# [Get|Set]ClusterWebUserDefaults
# [Get|Update|Set]AccountTemplate

############################## Mailbox Administration
# ListMailboxes
# [Create|Rename|Delete]Mailbox
# [Rename|Delete]Mailboxes
# GetMailboxInfo
# [Get|Set]MailboxACL
# GetMailboxRights
# SetMailboxClass

# [Get|Set]AccountSubscription
# [Get|Set]MailboxAliases

############################## Alerts Administration
# Get[Domain|Account|Server|Cluster]Alerts
# Set[Domain|Account|Server|Cluster]Alerts
# Post[Domain|Account|Server|Cluster]Alert
# Remove[Domain|Account|Server|Cluster]Alert

############################## Personal Web Site Administration
# GetWebFile
# PutWebFile
# RenameWebFile
# DeleteWebFile
# ListWebFiles
# GetWebFilesInfo

############################## Lists commands
# ListLists
# GetDomainLists
# GetAccountLists
# [Create|Rename|Delete|Get|Update]List
# List
# ListSubscribers
# GetSubscriberInfo
# SetPostingMode

############################## Web Skins Administration 
# ListDomainSkins( [domainName] )
# CreateDomainSkin(domainName,skinName)
# RenameDomainSkin(domainName,oldSkinName,newSkinName)
# DeleteDomainSkin(domainName,skinName)
# ListDomainSkinFiles(domainName,skinName)
# ReadDomainSkinFile(domainName,skinName,fileName)
# StoreDomainSkinFile(domainName,skinName,fileName,base64data)
# DeleteDomainSkinFile(domainName,skinName,fileName)

# ListServerSkins()
# CreateServerSkin(skinName)
# RenameServerSkin(oldSkinName,newSkinName)
# DeleteServerSkin(skinName)
# ListServerSkinFiles(skinName)
# ReadServerSkinFile(skinName,fileName)
# StoreServerSkinFile(skinName,fileName,base64data)
# DeleteServerSkinFile(skinName,fileName)

# ListClusterSkins()
# CreateClusterSkin(skinName)
# RenameClusterSkin(oldSkinName,newSkinName)
# DeleteClusterSkin(skinName)
# ListClusterSkinFiles(skinName)
# ReadClusterSkinFile(skinName,fileName)
# StoreClusterSkinFile(skinName,fileName,base64data)
# DeleteClusterSkinFile(skinName,fileName)

############################## Web Interface Tuning
# ListWebUserInterface
# GetWebUserInterface
# PutWebUserInterface
# DeleteWebUserInterface
# ClearWebUserCache

############################## Web Interface Integration
# [Create|Get|Kill]WebUserSession

############################## Server commands
# [Get|Update|Set]Module

# [Get|Set]BlacklistedIPs
# [Get|Set]ClientIPs 
# [Get|Set]WhiteHoleIPs 
# [Get|Set]Protection 
# [Get|Set]Banned

# [Get|Set]ClusterBlacklistedIPs
# [Get|Set]ClusterClientIPs 
# [Get|Set]ClusterWhiteHoleIPs 
# [Get|Set]ClusterProtection 
# GetClusterBanned

# [Get|Set][Server|Cluster]Rules
# RefreshOSData
# [Get|Set]RouterTable
# [Get|Set]RouterSettings
# [Get|Set]ClusterRouterTable
# [Get|Set]ntercept
# [Get|Set]ClusterIntercept

# Route

############################## Monitoring commands
# GetSNMPElement
# Shutdown

############################## Statistics commands
# [Get|Reset]AccountStat
# [Get|Reset]DomainStat

############################## Miscellaneous commands
# WriteLog
# ReleaseSMTPQueue
# RejectQueueMessage
# GetCurrentController
# GetTempClientIPs 
# RemoveAccountSubset

##############################################################

package CGP::CLI;

use strict;
use Carp;

# You may need to change this to "use IO::Socket::INET;" if you have INET.pm
use IO::Socket;

# You may need to install this module.
# See <http://search.cpan.org/search?module=Digest::MD5>
use Digest::MD5;


@CGP::CLI::ISA = qw(IO::Socket::INET);

$CGP::FALSE = 0;
$CGP::TRUE = 1;

$CGP::ERR_STRING = "No error";

$CGP::CLI_CODE_OK = 200;
$CGP::CLI_CODE_OK_INLINE = 201;

$CGP::CLI_CODE_PASSWORD = 300;
$CGP::CLI_CODE_UNKNOW_USER = 500;
$CGP::CLI_CODE_GEN_ERR = 501;
$CGP::CLI_CODE_STRANGE = 10000;

$CGP::CLI_CRLF = "\012";

$CGP::SECURE_LOGIN = 1;
$CGP::WEBUSER_LOGIN = 0;


sub new {
  my ($class, $params) = @_;

  my $login = delete $params->{'login'};
  my $password = delete $params->{'password'};

  my $isSecureLogin = delete $params->{'SecureLogin'};
  my $isWebUserLogin = delete $params->{'WebUserLogin'};
  
  
  $isSecureLogin = $CGP::SECURE_LOGIN unless defined $isSecureLogin;
  $isWebUserLogin = $CGP::WEBUSER_LOGIN unless defined $isWebUserLogin;


  croak 'You must pass login parameter to CGP::CLI::new'
    unless defined $login;
  croak 'You must pass password parameter to CGP::CLI::new'
    unless defined $password;

  croak 'SecureLogin and WebUserLogin are mutually exclusive'
    if($isSecureLogin && $isWebUserLogin);

  #print %$params;

  my $this = SUPER::new $class (%$params);

  unless(defined $this && $this) {
    $CGP::ERR_STRING="Can't open connection to CGPro Server";
    return undef;
  };

  $this->autoflush(1);

  unless($this->_parseResponse()) {
    $CGP::ERR_STRING="Can't read CGPro Server prompt";
    return undef;
  };

  if($isSecureLogin) {
    ${*$this}{'errMsg'} =~ /(\<.*\@*\>)/;

    my $md5=Digest::MD5->new;
    if($md5) {
      $md5->add($1.$password);
      $this->send('APOP '.$login.' '.$md5->hexdigest);
      $this->_parseResponse();
    } else {
      $CGP::ERR_STRING="Can't create MD5 object";
      close($this);
      return undef;
    }
  } elsif($isWebUserLogin) {
    $this->send('AUTH WEBUSER '.$login.' '.$password);
    $this->_parseResponse();
  
  } else {  
    $this->send('USER '.$login);
    $this->_parseResponse();
    return $CGP::FALSE unless ${*$this}{'errCode'} == $CGP::CLI_CODE_PASSWORD;
    $this->send('PASS '.$password);
    $this->_parseResponse();    
  }

  unless($this->isSuccess) {
    $CGP::ERR_STRING=${*$this}{'errMsg'};
    close($this);
    return undef;
  }
  $this->send('INLINE');
  $this->_parseResponse();
  $this->setStringsTranslateMode(0);

  $this;
}

sub getErrCode {
  my $this = shift;
  return ${*$this}{'errCode'};
}

sub getErrMessage {
  my $this = shift;
  return ${*$this}{'errMsg'};
}

sub getErrCommand {
  my $this = shift;
  return ${*$this}{'currentCGateCommand'};
}

sub isSuccess {
  my $this = shift;
  return (${*$this}{'errCode'} == $CGP::CLI_CODE_OK || ${*$this}{'errCode'} == $CGP::CLI_CODE_OK_INLINE);
}

sub setDebug {
  my ($this, $debugFlag) = @_;
  ${*$this}{'debug'} = $debugFlag;    
}

sub setStringsTranslateMode {
  my ($this, $onFlag) = @_;
  ${*$this}{'translateStrings'} = $onFlag;    
}

sub Logout {
  my $this = shift;
  $this->send('QUIT');
  $this->_parseResponse();
}

sub NewPassword {
  my ($this, $newPassword) = @_;
  croak 'usage CGP::CLI->NewPassword($newPassword)'
    unless defined $newPassword;
  $this->send('NEWPASS '.$newPassword);
  $this->_parseResponse();
}

sub SendCommand {
  my ($this, $command) = @_;
  croak 'usage CGP::CLI->SendCommand($commandString)'
    unless defined $command;
  $this->send($command);
  $this->_parseResponse();
}    

sub GetResponseData {
  my ($this) = @_;
  $this->parseWords($this->getWords);
}    


####################################################################
#    Account commands

sub ListAccounts {
  my ($this, $domainName) = @_;
  my $line = 'ListAccounts';
  $line .= ' '.$domainName if $domainName;
  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}    

sub CreateAccount {
  my ($this) = shift;;
  my %params = (@_);

  croak 'usage CGP::CLI->CreateAccount(accountName => \'newAccountName\',
                            accountType => \'accountType\',
                            externalFlag => \'externalFlag\',
                            settings     => $settings)'
      unless exists $params{accountName};
  my $line = 'CreateAccount '.$params{accountName};
  $line .= ' ' . $params{accountType} if exists $params{accountType};
  $line .= ' ' . 'external' if exists $params{externalFlag};
  $line .= ' ' . $this->printWords($params{settings}) if exists $params{settings};

  $this->send($line);
  $this->_parseResponse();
}

sub RenameAccount {
  my ($this, $oldAccountName, $newAccountName) = @_;
  croak 'usage CGP::CLI->RenameAccount($oldAccountName, $newAccountName)'
      unless defined $oldAccountName && defined $newAccountName;
  $this->send('RenameAccount '.$oldAccountName.' into '.$newAccountName);
  $this->_parseResponse();
}

sub DeleteAccount {
  my ($this, $accountName) = @_;
  croak 'usage CGP::CLI->DeleteAccount($accountName)'
    unless defined $accountName;
  $this->send('DeleteAccount '.$accountName);
  $this->_parseResponse();
}

sub GetAccountSettings {
  my ($this, $accountName) = @_;
  croak 'usage CGP::CLI->GetAccountSettings($accountName)'
    unless defined $accountName;
  $this->send('GetAccountSettings '.$accountName);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub GetAccount {
  GetAccountSettings(@_);
}

sub GetAccountEffectiveSettings {
  my ($this, $accountName) = @_;
  croak 'usage CGP::CLI->GetAccountEffectiveSettings($accountName)'
    unless defined $accountName;
  $this->send('GetAccountEffectiveSettings '.$accountName);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub UpdateAccountSettings {
  my ($this, $accountName, $params) = @_;
  croak 'usage CGP::CLI->UpdateAccountSettings($accountName, \%settings)'
    unless defined $accountName;
  $this->send('UpdateAccountSettings '.$accountName.' '.$this->printWords($params));
  $this->_parseResponse();
}

sub UpdateAccount {
  UpdateAccountSettings(@_);
}

sub SetAccountSettings {
  my ($this, $accountName, $params) = @_;
  croak 'usage CGP::CLI->SetAccountSettings($accountName, \%settings)'
    unless defined $accountName;
  $this->send('SetAccountSettings '.$accountName.' '.$this->printWords($params));
  $this->_parseResponse();
}

sub SetAccount {
  SetAccountSettings(@_);
}

sub SetAccountPassword {
  my ($this, $accountName, $newPass) = @_;
  croak 'usage CGP::CLI->SetAccountPassword($accountName, $newPassword)'
    unless defined $accountName && defined $newPass;
  $this->send('SetAccountPassword '.$accountName.' TO '.$this->printWords($newPass));
  $this->_parseResponse();
}

sub VerifyAccountPassword {
  my ($this, $accountName, $pass) = @_;
  croak 'usage CGP::CLI->VerifyAccountPassword($accountName, $password)'
    unless defined $accountName && defined $pass;
  $this->send('VerifyAccountPassword '.$accountName.' PASSWORD '.$this->printWords($pass));
  $this->_parseResponse();
}


sub GetAccountAliases {
  my ($this, $accountName) = @_;
  croak 'usage CGP::CLI->GetAccountAliases($accountName)'
    unless defined $accountName;
  $this->send('GetAccountAliases '.$accountName);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetAccountAliases {
  my ($this, $accountName, $aliases) = @_;
  croak 'usage CGP::CLI->SetAccountAliases($accountName, \@aliases)'
    unless defined $accountName && defined $aliases;
  $this->send('SetAccountAliases '.$accountName.' '.$this->printWords($aliases));
  $this->_parseResponse();
}

sub GetAccountRules {
  my ($this, $accountName) = @_;
  croak 'usage CGP::CLI->GetAccountRules($accountName)'
    unless defined $accountName;
  $this->send('GetAccountRules '.$accountName);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetAccountRules {
  my ($this, $accountName, $rules) = @_;
  croak 'usage CGP::CLI->SetAccountRules($accountName, \@rules)'
    unless defined $accountName && defined $rules;
  $this->send('SetAccountRules '.$accountName.' '.$this->printWords($rules));
  $this->_parseResponse();
}

sub GetAccountRPOP {
  my ($this, $accountName) = @_;
  croak 'usage CGP::CLI->GetAccountRPOP($accountName)'
      unless defined $accountName;
  $this->send('GetAccountRPOP '.$accountName);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetAccountRPOP {
  my ($this, $accountName, $newRecords) = @_;
  croak 'usage CGP::CLI->SetAccountAliases($accountName, \@newRecords)'
    unless defined $accountName && defined $newRecords;
  $this->send('SetAccountRPOP '.$accountName.' '.$this->printWords($newRecords));
  $this->_parseResponse();
}

sub GetAccountRights {
  my ($this, $account) = @_;
  croak 'usage CGP::CLI->GetAccountRights($account)'
    unless defined $account;
  $this->send('GetAccountRights '.$account);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetAccountRights {
  my ($this, $account, $list) = @_;
  croak 'usage CGP::CLI->SetAccountRigthts($acount, \@list)'
    unless defined $account && defined $list;
  my $line = 'SetAccountRights '.$account.' '.$this->printWords($list);

  $this->send($line);
  $this->_parseResponse();
}

sub GetAccountInfo {
  my ($this, $account, $key) = @_;
  croak 'usage CGP::CLI->GetAccountInfo($account,$key)'
    unless defined $account && defined $key;       
  $this->send('GetAccountInfo '.$account.' Key '.$key);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);      
}

sub GetWebUser {
  my ($this, $account) = @_;
  croak 'usage CGP::CLI->GetWebUser($account)'
    unless defined $account;
  $this->send('GetWebUser '.$account);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetWebUser {
  my ($this, $account, $settings) = @_;
  croak 'usage CGP::CLI->SetWebUser($acount, \%settings)'
    unless defined $account && defined $settings;
  my $line = 'SetWebUser '.$account.' '.$this->printWords($settings);

  $this->send($line);
  $this->_parseResponse();
}

sub GetEffectiveWebUser {
  my ($this, $account) = @_;
  croak 'usage CGP::CLI->GetEffectiveWebUser($account)'
    unless defined $account;
  $this->send('GetEffectiveWebUser '.$account);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

#################################################################
#  Group managent commands

sub ListGroups {
  my ($this, $domainName) = @_;
  my $line = 'ListGroups';
  $line .= ' '.$domainName if $domainName;
  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}    

sub CreateGroup {
  my ($this, $groupName, $params) = @_;
  croak 'usage CGP::CLI->CreateGroup($groupName[, \%params])'
    unless defined $groupName;
  my $line = 'CreateGroup '.$groupName;
  $line .= ' '.$this->printWords($params) if $params;
  $this->send($line);
  $this->_parseResponse(); 
}

sub RenameGroup {
  my ($this, $oldGroupName, $newGroupName) = @_;
  croak 'usage CGP::CLI->RenameGroup($oldGroupName, $newGroupName)'
    unless defined $oldGroupName && defined $newGroupName;
  $this->send('RenameGroup '.$oldGroupName.' into '.$newGroupName);
  $this->_parseResponse();    
}

sub DeleteGroup {
  my ($this, $groupName) = @_;
  croak 'usage CGP::CLI->DeleteGroup($groupName)'
    unless defined $groupName;
  $this->send('DeleteGroup '.$groupName);
  $this->_parseResponse();    
}

sub GetGroup {
  my ($this, $groupName) = @_;
  croak 'usage CGP::CLI->GetGroup($groupName)'
    unless defined $groupName;
  $this->send('GetGroup '.$groupName);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);      
}

sub SetGroup {
  my ($this, $groupName, $params) = @_;
  croak 'usage CGP::CLI->SetGroup($groupName, \%settings)'
    unless defined $groupName && defined $params;
  $this->send('SetGroup '.$groupName.' '.$this->printWords($params));
  $this->_parseResponse();
}


#################################################################
#  Forwarder managent commands

sub ListForwarders {
  my ($this, $domainName) = @_;
  my $line = 'ListForwarders';
  $line .= ' ' .$domainName if $domainName;
  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}    

sub CreateForwarder {
  my ($this, $forwarderName, $address) = @_;
  croak 'usage CGP::CLI->CreateForwarder($forwarderName, $address)'
    unless defined $forwarderName && defined $address;
  $this->send('CreateForwarder '.$forwarderName.' TO '.$this->printWords($address));
  $this->_parseResponse(); 
}

sub DeleteForwarder {
  my ($this, $forwarderName) = @_;
  croak 'usage CGP::CLI->DeleteForwarder($forwarderName)'
    unless defined $forwarderName;
  $this->send('DeleteForwarder '.$forwarderName);
  $this->_parseResponse();    
}

sub GetForwarder {
  my ($this, $forwarderName) = @_;
  croak 'usage CGP::CLI->GetForwarder($forwarderName)'
    unless defined $forwarderName;
  $this->send('GetForwarder '.$forwarderName);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);      
}

#################################################################
#  Domain managent commands

sub ListDomains {
  my $this = shift;
  $this->send('ListDomains');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub MainDomainName {
  my $this = shift;
  $this->send('MainDomainName');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub GetDomainSettings {
  my ($this, $domainName) = @_;

  my $line = 'GetDomainSettings';
  $line .= ' '.$domainName if($domainName);

  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub GetDomain {
  GetDomainSettings(@_);
}

sub GetDomainEffectiveSettings {
  my ($this, $domainName) = @_;
  my $line = 'GetDomainEffectiveSettings';
  $line .= ' '.$domainName if($domainName);
  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub UpdateDomainSettings {
  my ($this) = shift;
  my %params = (@_);

  croak 'usage CGP::CLI->UpdateDomainSettings(domain => \'domainName\',settings => {settings})'
    unless exists $params{settings};

  my $line = 'UpdateDomainSettings';
  $line .= ' '.$params{domain} if exists $params{domain};
  $this->send($line.' '.$this->printWords($params{settings}));
  $this->_parseResponse();
}

sub UpdateDomain {
  UpdateDomainSettings(@_);
}

sub SetDomainSettings {
  my ($this) = shift;
  my %params = (@_);

  croak 'usage CGP::CLI->SetDomainSettings(domain => \'domainName\',settings => {settings})'
    unless exists $params{settings};

  my $line = 'SetDomainSettings';
  $line .= ' '.$params{domain} if exists $params{domain};
  $this->send($line.' '.$this->printWords($params{settings}));
  $this->_parseResponse();
}

sub SetDomain {
  SetDomainSettings(@_);
}


sub CreateDomain {
  my ($this, $domainName, $params) = @_;
  croak 'usage CGP::CLI->CreateDomain($domainName[, \%params])'
    unless defined $domainName;
  my $line = 'CreateDomain '.$domainName;
  $line .= ' '.$this->printWords($params) if $params;
  $this->send($line);
  $this->_parseResponse();
}

sub RenameDomain {
  my ($this, $oldDomainName, $newDomainName) = @_;
  croak 'usage CGP::CLI->RenameDomain($oldDomainName, $newDomainName)'
    unless defined $oldDomainName && defined $newDomainName;
  $this->send('RenameDomain '.$oldDomainName.' into '.$newDomainName );
  $this->_parseResponse();
}

sub DeleteDomain {
  my ($this, $domainName, $force) = @_;
  croak 'usage CGP::CLI->DeleteDomain($domainName[, $force])'
    unless defined $domainName;
  my $line = 'DeleteDomain '.$domainName;
  $line .= ' force' if $force;
  $this->send($line);
  $this->_parseResponse();
}

sub CreateSharedDomain {
  my ($this, $domainName, $params) = @_;
  croak 'usage CGP::CLI->CreateSharedDomain($domainName[, \%params])'
    unless defined $domainName;
  my $line = 'CreateSharedDomain '.$domainName;
  $line .= ' '.$this->printWords($params) if $params;
  $this->send($line);
  $this->_parseResponse();
}

sub CreateDirectoryDomain {
  my ($this, $domainName, $params) = @_;
  croak 'usage CGP::CLI->CreateDirectoryDomain($domainName[, \%params])'
    unless defined $domainName;
  my $line = 'CreateDirectoryDomain '.$domainName;
  $line .= ' '.$this->printWords($params) if $params;
  $this->send($line);
  $this->_parseResponse();
}

sub ReloadDirectoryDomains {
  my ($this) = @_;
  $this->send('ReloadDirectoryDomains');
  $this->_parseResponse();
}

sub GetDomainRules {
  my ($this, $domainName) = @_;
  croak 'usage CGP::CLI->GetDomainRules($domainName)'
    unless defined $domainName;
  $this->send('GetDomainRules '.$domainName);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetDomainRules {
  my ($this, $domainName, $rules) = @_;
  croak 'usage CGP::CLI->SetDomainRules($domainName, \@rules)'
    unless defined $domainName && defined $rules;
  $this->send('SetDomainRules '.$domainName.' '.$this->printWords($rules));
  $this->_parseResponse();
}

sub GetDomainAliases {
  my ($this, $domain) = @_;

  my $line = 'GetDomainAliases';
  $line .= ' '.$domain if $domain;
  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}


sub SetDomainAliases {
  my ($this, $domain, $aliases) = @_;
  croak 'usage CGP::CLI->SetDomainAliases($domainName, \@aliases)'
    unless defined $domain && defined $aliases;
  $this->send('SetDomainAliases '.$domain.' '.$this->printWords($aliases));
  $this->_parseResponse();
}

sub ListAdminDomains {
  my ($this, $domain) = @_;
  my $line = 'ListAdminDomains';
  $line .= ' '.$domain if $domain;
  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub InsertDirectoryRecords {
  my ($this, $domain) = @_;
  my $line = 'InsertDirectoryRecords';
  $line .= ' '.$domain if $domain;
  $this->send($line);
  $this->_parseResponse();
}
sub DeleteDirectoryRecords {
  my ($this, $domain) = @_;
  my $line = 'DeleteDirectoryRecords';
  $line .= ' '.$domain if $domain;
  $this->send($line);
  $this->_parseResponse();
}


sub GetDirectoryIntegration {
  my $this = shift;
  $this->send('GetDirectoryIntegration');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetDirectoryIntegration {
  my ( $this, $dict ) = @_;
  croak 'usage CGP::CLI->SetDirectoryIntegration(\%settings)'
    unless defined $dict;

  $this->send('SetDirectoryIntegration '.$this->printWords($dict));
  $this->_parseResponse();
}

sub GetClusterDirectoryIntegration {
  my $this = shift;
  $this->send('GetClusterDirectoryIntegration');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetClusterDirectoryIntegration {
  my ( $this, $dict ) = @_;
  croak 'usage CGP::CLI->SetClusterDirectoryIntegration(\%settings)'
    unless defined $dict;

  $this->send('SetClusterDirectoryIntegration '.$this->printWords($dict));
  $this->_parseResponse(); 
}


sub GetDomainDefaults {
  my $this = shift;
  $this->send('GetDomainDefaults');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub UpdateDomainDefaults {
  my ( $this, $dict ) = @_;
  croak 'usage CGP::CLI->UpdateDomainDefaults(\%settings)'
    unless defined $dict;

  $this->send('UpdateDomainDefaults '.$this->printWords($dict));
  $this->_parseResponse(); 
}

sub SetDomainDefaults {
  my ( $this, $dict ) = @_;
  croak 'usage CGP::CLI->SetDomainDefaults(\%settings)'
    unless defined $dict;
  $this->send('SetDomainDefaults '.$this->printWords($dict));
  $this->_parseResponse();
}

sub GetClusterDomainDefaults {
  my $this = shift;
  $this->send('GetClusterDomainDefaults');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub UpdateClusterDomainDefaults {
  my ( $this, $dict ) = @_;
  $this->send('UpdateClusterDomainDefaults '.$this->printWords($dict));
  $this->_parseResponse();
}

sub SetClusterDomainDefaults {
  my ( $this, $dict ) = @_;
  $this->send('SetClusterDomainDefaults '.$this->printWords($dict));
  $this->_parseResponse();
}


sub GetAllAccountsDefaults {
  my $this = shift;
  $this->send('GetAllAccountsDefaults');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub UpdateAllAccountsDefaults {
  my ( $this, $dict ) = @_;
  $this->send('UpdateAllAccountsDefaults '.$this->printWords($dict));
  $this->_parseResponse();
}

sub SetAllAccountsDefaults {
  my ( $this, $dict ) = @_;
  $this->send('SetAllAccountsDefaults '.$this->printWords($dict));
  $this->_parseResponse();
}

sub GetClusterAccountDefaults {
  my $this = shift;
  $this->send('GetClusterAccountDefaults');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub UpdateClusterAccountDefaults {
  my ( $this, $dict ) = @_;
  $this->send('UpdateClusterAccountDefaults '.$this->printWords($dict));
  $this->_parseResponse();
}

sub SetClusterAccountDefaults {
  my ( $this, $dict ) = @_;
  $this->send('SetClusterAccountDefaults '.$this->printWords($dict));
  $this->_parseResponse();
}

sub GetServerWebUserDefaults {
  my $this = shift;
  $this->send('GetServerWebUserDefaults');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}
sub SetServerWebUserDefaults {
  my ( $this, $dict ) = @_;
  $this->send('SetServerWebUserDefaults '.$this->printWords($dict));
  $this->_parseResponse();
}

sub GetClusterWebUserDefaults {
  my $this = shift;
  $this->send('GetClusterWebUserDefaults');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}
sub SetClusterWebUserDefaults {
  my ( $this, $dict ) = @_;
  $this->send('SetClusterWebUserDefaults '.$this->printWords($dict));
  $this->_parseResponse();
}


sub GetAccountLocation {
  my ( $this, $account ) = @_;
  $this->send('GetAccountLocation '.$account);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub GetAccountDefaults {
  my ($this, $domain) = @_;

  my $line = 'GetAccountDefaults';
  $line .= ' '.$domain if($domain);
  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub UpdateAccountDefaults {
  my ($this) = shift;
  my %params = (@_);

  croak 'usage CGP::CLI->UpdateAccountDefaults(domain => \'domainName\',settings => {settings})'
    unless exists $params{settings};

  my $line = 'UpdateAccountDefaults';
  $line .= ' '.$params{domain} if exists $params{domain};

  $this->send($line . ' ' . $this->printWords($params{settings}));
  $this->_parseResponse();
}

sub SetAccountDefaults {
  my ($this) = shift;
  my %params = (@_);

  croak 'usage CGP::CLI->SetAccountDefaults(domain => \'domainName\',settings => {settings})'
    unless exists $params{settings};

  my $line = 'SetAccountDefaults';
  $line .= ' '.$params{domain} if exists $params{domain};

  $this->send($line . ' ' . $this->printWords($params{settings}));
  $this->_parseResponse();
}

sub GetWebUserDefaults {
  my ($this, $domain) = @_;

  my $line = 'GetWebUserDefaults';
  $line .= ' '.$domain if($domain);
        
  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetWebUserDefaults {
  my ($this) = shift;;
  my %params = (@_);
  croak 'usage CGP::CLI->SetWebUserDefaults(domain => \'domainName\',settings => {settings})'
    unless exists $params{settings};

  my $line = 'SetWebUserDefaults';
  $line .= ' ' .$params{domain} if exists $params{domain};

  $this->send($line . ' ' . $this->printWords($params{settings}));
  $this->_parseResponse();
}


sub GetAccountTemplate {
  my ($this, $domain) = @_;

  my $line = 'GetAccountTemplate';
  $line .= ' '.$domain if($domain);

  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub UpdateAccountTemplate {
  my ($this) = shift;;
  my %params = (@_);

  croak 'usage CGP::CLI->UpdateAccountTemplate(domain => \'domainName\',settings => {settings})'
    unless exists $params{settings};

  my $line = 'UpdateAccountTemplate';
  $line .= ' '.$params{domain} if exists $params{domain};

  $this->send($line.' '.$this->printWords($params{settings}));
  $this->_parseResponse();
}

sub SetAccountTemplate {
  my ($this) = shift;;
  my %params = (@_);

  croak 'usage CGP::CLI->SetAccountTemplate(domain => \'domainName\',settings => {settings})'
    unless exists $params{settings};

  my $line = 'SetAccountTemplate';
  $line .= ' '.$params{domain} if exists $params{domain};

  $this->send($line.' '.$this->printWords($params{settings}));
  $this->_parseResponse();
}

#################################################################
#  Mailbox managent commands

sub ListMailboxes {
  my ($this) = shift;;
  my %params = (@_);

  croak 'usage CGP::CLI->ListMailboxes(accountName => \'account\',filter => \'*\',authAccountName => \'extAccount\')'
      unless exists $params{accountName};

  my $line = 'ListMailboxes '.$params{accountName};
  $line .= ' FILTER '.$this->printWords($params{filter}) if exists $params{filter};
  $line .= ' AUTH '.$params{authAccountName} if exists $params{authAccountName};

  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub CreateMailbox {
  my ($this,$accountName,$mailboxName,$authAccountName) = @_;
 
 
  croak 'usage CGP::CLI->CreateMailbox(accountName,mailboxName[,authAccountName])'
      unless (defined $accountName && defined $mailboxName);
      
  my $line = 'CREATEMAILBOX '.$accountName;
  $line .= ' MAILBOX '.$this->printWords($mailboxName);
  $line .= ' AUTH '.$authAccountName if defined $authAccountName;

  $this->send($line);
  $this->_parseResponse();
}

sub RenameMailbox {   
  my ($this,$accountName,$oldMailboxName,$newMailboxName,$authAccountName) = @_;
  
  croak 'usage CGP::CLI->RenameMailbox(accountName,oldMailboxName,newMailboxName[,authAccountName])'
      unless (defined $accountName && defined $oldMailboxName && defined $newMailboxName);
      
  my $line = 'RENAMEMAILBOX '.$accountName;
  $line .= ' MAILBOX '.$this->printWords($oldMailboxName);
  $line .= ' INTO '.$this->printWords($newMailboxName);
  $line .= ' AUTH '.$authAccountName if defined $authAccountName;

  $this->send($line);
  $this->_parseResponse();
}

sub RenameMailboxes {   
  my ($this,$accountName,$oldMailboxName,$newMailboxName,$authAccountName) = @_;
  
  croak 'usage CGP::CLI->RenameMailboxes(accountName,oldMailboxName,newMailboxName[,authAccountName])'
      unless (defined $accountName && defined $oldMailboxName && defined $newMailboxName);
      
  my $line = 'RENAMEMAILBOX '.$accountName;
  $line .= ' MAILBOXES '.$this->printWords($oldMailboxName);
  $line .= ' INTO '.$this->printWords($newMailboxName);
  $line .= ' AUTH '.$authAccountName if defined $authAccountName;

  $this->send($line);
  $this->_parseResponse();
}

sub DeleteMailbox {
  my ($this,$accountName,$mailboxName,$authAccountName) = @_;
  
  croak 'usage CGP::CLI->DeleteMailbox(accountName,mailboxName[,authAccountName])'
      unless (defined $accountName && defined $mailboxName);
      
  my $line = 'DELETEMAILBOX '.$accountName;
  $line .= ' MAILBOX '.$this->printWords($mailboxName);
  $line .= ' AUTH '.$authAccountName if defined $authAccountName;

  $this->send($line);
  $this->_parseResponse();
}

sub DeleteMailboxes {
  my ($this,$accountName,$mailboxName,$authAccountName) = @_;
  
  croak 'usage CGP::CLI->DeleteMailbox(accountName,mailboxName[,authAccountName])'
      unless (defined $accountName && defined $mailboxName);
      
  my $line = 'DELETEMAILBOX '.$accountName;
  $line .= ' MAILBOXES '.$this->printWords($mailboxName);
  $line .= ' AUTH '.$authAccountName if defined $authAccountName;

  $this->send($line);
  $this->_parseResponse();
}

sub GetMailboxInfo {
  my ($this,$accountName,$mailboxName,$authAccountName) = @_;

  croak 'usage CGP::CLI->GetMailboxInfo(accountName,mailboxName[,authAccountName])'
       unless (defined $accountName && defined $mailboxName);
     
  my $line = 'GETMAILBOXINFO '.$accountName;
  $line .= ' MAILBOX '.$this->printWords($mailboxName);
  $line .= ' AUTH '.$authAccountName if defined $authAccountName;

  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub GetMailboxACL {   
  my ($this,$accountName,$mailboxName,$authAccountName) = @_;

  croak 'usage CGP::CLI->GetMailboxACL(accountName,mailboxName[,authAccountName])'
       unless (defined $accountName && defined $mailboxName);
     
  my $line = 'GETMAILBOXACL '.$accountName;
  $line .= ' MAILBOX '.$this->printWords($mailboxName);
  $line .= ' AUTH '.$authAccountName if defined $authAccountName;

  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetMailboxACL {
  my ($this,$accountName,$mailboxName,$newACL,$authAccountName) = @_;

  croak 'usage CGP::CLI->SetMailboxACL(accountName,mailboxName,\@newACL[,authAccountName])'
       unless (defined $accountName && defined $mailboxName && defined $newACL);
     
  my $line = 'SETMAILBOXACL '.$accountName;
  $line .= ' MAILBOX '.$this->printWords($mailboxName);
  $line .= ' AUTH '.$authAccountName if defined $authAccountName;

  $this->send($line.' '.$this->printWords($newACL));
  $this->_parseResponse();
}


sub GetMailboxRights {
  my ($this,$accountName,$mailboxName,$authAccountName) = @_;

  croak 'usage CGP::CLI->GetMailboxRights(accountName,mailboxName,authAccountName)'
       unless (defined $accountName && defined $mailboxName && defined $authAccountName);
     
  my $line = 'GETMAILBOXRIGHTS '.$accountName;
  $line .= ' MAILBOX '.$this->printWords($mailboxName);
  $line .= ' AUTH '.$authAccountName;

  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetMailboxClass {
  my ($this,$accountName,$mailboxName,$class,$authAccountName) = @_;

  croak 'usage CGP::CLI->SetMailboxClass(accountName,mailboxName,class [,authAccountName])'
       unless (defined $accountName && defined $mailboxName && defined $class);
     
  my $line = 'SetMailboxClass '.$accountName;
  $line .= ' MAILBOX '.$this->printWords($mailboxName);
  $line .= ' AUTH '.$authAccountName if(defined $authAccountName);
  $line .= ' CLASS '.$class;

  $this->send($line);
  return undef unless $this->_parseResponse();
}


sub GetAccountSubscription {
  my ($this,$accountName) = @_;
  croak 'usage CGP::CLI->GetAccountSubscription(accountName)'
       unless defined $accountName;
     
  $this->send('GetAccountSubscription '.$accountName);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetAccountSubscription {
  my ($this,$accountName,$newSubscription) = @_;
  croak 'usage CGP::CLI->SetAccountSubscription(accountName,\%newSubscription)'
       unless (defined $accountName && defined $newSubscription);
     
  $this->send('SetAccountSubscription '.$accountName.' '.$this->printWords($newSubscription));
  $this->_parseResponse();
}

sub GetMailboxAliases {
  my ($this,$accountName) = @_;
  croak 'usage CGP::CLI->GetMailboxAliases(accountName)'
       unless defined $accountName;
     
  $this->send('GetMailboxAliases '.$accountName);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetMailboxAliases {
  my ($this,$accountName,$newAliases) = @_;
  croak 'usage CGP::CLI->SetMailboxAliases(accountName,\%newAliases)'
       unless (defined $accountName && defined $newAliases);
     
  $this->send('SetMailboxAliases '.$accountName.' '.$this->printWords($newAliases));
  $this->_parseResponse();
}


#################################################################
#   Alerts Administration

sub GetDomainAlerts {
  my ($this, $domain) = @_;

  my $line = 'GetDomainAlerts';
  $line .= ' '.$domain if $domain;
  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetDomainAlerts {
  my ($this, $domain, $alerts) = @_;
  croak 'usage CGP::CLI->SetDomainAlerts($domainName, \@alerts)'
    unless defined $domain && defined $alerts;
  $this->send('SetDomainAlerts '.$domain.' '.$this->printWords($alerts));
  $this->_parseResponse();
}

sub PostDomainAlert {
  my ($this, $domain, $alert) = @_;
  croak 'usage CGP::CLI->PostDomainAlert($domainName, $alertString)'
    unless defined $domain && defined $alert;
  $this->send('PostDomainAlert '.$domain.' ALERT '.$this->printWords($alert));
  $this->_parseResponse();
}

sub RemoveDomainAlert {
  my ($this, $domain, $timeStamp) = @_;
  croak 'usage CGP::CLI->RemoveDomainAlert($domainName, $timeStamp)'
    unless defined $domain && defined $timeStamp;
  $this->send('RemoveDomainAlert '.$domain.' ALERT '.$timeStamp);
  $this->_parseResponse();
}

sub GetAccountAlerts {
  my ($this, $account) = @_;
  $this->send('GetAccountAlerts '.$account);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetAccountAlerts {
  my ($this, $account, $alerts) = @_;
  croak 'usage CGP::CLI->SetAccountAlerts($account, \@alerts)'
    unless defined $account && defined $alerts;
  $this->send('SetAccountAlerts '.$account.' '.$this->printWords($alerts));
  $this->_parseResponse();
}

sub PostAccountAlert {
  my ($this, $account, $alert) = @_;
  croak 'usage CGP::CLI->PostAccountAlert($account, $alertString)'
    unless defined $account && defined $alert;
  $this->send('PostAccountAlert '.$account.' ALERT '.$this->printWords($alert));
  $this->_parseResponse();
}

sub RemoveAccountAlert {
  my ($this, $account, $timeStamp) = @_;
  croak 'usage CGP::CLI->RemoveAccountAlert($account, $timeStamp)'
    unless defined $account && defined $timeStamp;
  $this->send('RemoveAccountAlert '.$account.' ALERT '.$timeStamp);
  $this->_parseResponse();
}


sub GetServerAlerts {
  my ($this) = @_;
  $this->send('GetServerAlerts');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetServerAlerts {
  my ($this, $alerts) = @_;
  croak 'usage CGP::CLI->SetServerAlerts(\@alerts)'
    unless defined $alerts;
  $this->send('SetServerAlerts '.$this->printWords($alerts));
  $this->_parseResponse();
}

sub PostServerAlert {
  my ($this,  $alert) = @_;
  croak 'usage CGP::CLI->PostServerAlert($alertString)'
    unless defined $alert;
  $this->send('PostServerAlert '.$this->printWords($alert));
  $this->_parseResponse();
}

sub RemoveServerAlert {
  my ($this, $timeStamp) = @_;
  croak 'usage CGP::CLI->RemoveServerAlert($timeStamp)'
    unless defined $timeStamp;
  $this->send('RemoveServerAlert '.$timeStamp);
  $this->_parseResponse();
}

sub GetClusterAlerts {
  my ($this) = @_;
  $this->send('GetClusterAlerts');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetClusterAlerts {
  my ($this, $alerts) = @_;
  croak 'usage CGP::CLI->SetClusterAlerts(\@alerts)'
    unless defined $alerts;
  $this->send('SetClusterAlerts '.$this->printWords($alerts));
  $this->_parseResponse();
}

sub PostClusterAlert {
  my ($this,  $alert) = @_;
  croak 'usage CGP::CLI->PostClusterAlert($alertString)'
    unless defined $alert;
  $this->send('PostClusterAlert '.$this->printWords($alert));
  $this->_parseResponse();
}

sub RemoveClusterAlert {
  my ($this, $timeStamp) = @_;
  croak 'usage CGP::CLI->RemoveClusterAlert($timeStamp)'
    unless defined $timeStamp;
  $this->send('RemoveClusterAlert '.$timeStamp);
  $this->_parseResponse();
}

#################################################################
#   Personal Web Site Administration

sub GetWebFile {
  my ($this,$accountName,$fileName) = @_;

  croak 'usage CGP::CLI->GetWebFile(accountName,fileName)'
       unless (defined $accountName && defined $fileName);
  $this->send('GetWebFile '.$accountName.' FILE '.$this->printWords($fileName));
  return undef unless $this->_parseResponse;
  $this->parseWords($this->getWords);
}

sub PutWebFile {
  my ($this,$accountName,$fileName,$data) = @_;

  croak 'usage CGP::CLI->PutWebFile(accountName,fileName,data)'
       unless (defined $accountName && defined $fileName && defined $data);
  $this->send('PutWebFile '.$accountName.' FILE '.$this->printWords($fileName).' DATA "'.$data.'"');
  $this->_parseResponse;
}

sub RenameWebFile {
  my ($this,$accountName,$oldFileName,$newFileName) = @_;

  croak 'usage CGP::CLI->RenameWebFile(accountName,oldFileName,newFileName)'
       unless (defined $accountName && defined $oldFileName && defined $newFileName);
  $this->send('RenameWebFile '.$accountName.' FILE '.$this->printWords($oldFileName).' INTO '.$this->printWords($newFileName));
  $this->_parseResponse;
}

sub DeleteWebFile {
  my ($this,$accountName,$fileName) = @_;

  croak 'usage CGP::CLI->DeleteWebFile(accountName,fileName)'
       unless (defined $accountName && defined $fileName);
  $this->send('DeleteWebFile '.$accountName.' FILE '.$this->printWords($fileName));
  $this->_parseResponse;
}

sub ListWebFiles {
  my ($this,$accountName,$filePath) = @_;

  croak 'usage CGP::CLI->ListWebFiles(accountName [,filePath])'
       unless defined $accountName;
  my $line = 'ListWebFiles '.$accountName;
  $line .= ' PATH '.$this->printWords($filePath) if $filePath;
  $this->send($line);
  return undef unless $this->_parseResponse;
  $this->parseWords($this->getWords);
}

sub GetWebFilesInfo {
  my ($this,$accountName) = @_;

  croak 'usage CGP::CLI->InfoWebFiles(accountName)'
       unless defined $accountName;
  $this->send('GetWebFilesInfo '.$accountName);
  return undef unless $this->_parseResponse;
  $this->parseWords($this->getWords);
}

#################################################################
#   List management commands

sub ListLists {
  my ( $this, $domain ) = @_;
  my $line = 'LISTLISTS';
  $line .= ' '.$domain if $domain;
  $this->send($line);
  return undef unless $this->_parseResponse;
  $this->parseWords($this->getWords);
}

sub GetDomainLists {
  my ( $this, $domain ) = @_;
  my $line = 'GetDomainLists';
  $line .= ' '.$domain if $domain;
  $this->send($line);
  return undef unless $this->_parseResponse;
  $this->parseWords($this->getWords);
}

sub GetAccountLists {
  my ( $this, $accountName ) = @_;
  croak 'usage CGP::CLI->GetAccoountLists($accountName)'
      unless defined $accountName;

  $this->send('GetAccountLists '.$accountName);
  return undef unless $this->_parseResponse;
  $this->parseWords($this->getWords);
}

sub CreateList {
  my ($this, $listName, $accountName) = @_;
  croak 'usage CGP::CLI->CreateList($listName, $accountName)'
      unless defined $listName && defined $accountName;
  $this->send('CREATELIST '.$listName.' for '.$accountName);
  $this->_parseResponse();
}

sub RenameList {
  my ($this, $oldListName, $newListName) = @_;
  croak 'usage CGP::CLI->RenameList($oldListName, $newListName)'
      unless defined $oldListName && defined $newListName;
  $this->send('RENAMELIST '.$oldListName.' into '.$newListName);
  $this->_parseResponse();
}

sub DeleteList {
  my ( $this, $listName ) = @_;
  croak 'usage CGP::CLI->DeleteList($listName)'
      unless defined $listName;

  $this->send('DELETELIST '.$listName);
  $this->_parseResponse();
}

sub GetList {
  my ( $this, $listName ) = @_;
  croak 'usage CGP::CLI->GetList($listName)'
      unless defined $listName;
      
  $this->send('GETLIST '.$listName);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub UpdateList {
  my ( $this, $listName, $dict ) = @_;
  croak 'usage CGP::CLI->UpdateList($listName,\%params)'
      unless defined $listName && defined $dict;
  
  $this->send('UPDATELIST '.$listName.' '.$this->printWords($dict) );
  $this->_parseResponse();
}

sub List {
  my ( $this, $listName, $command, $subscriber, @options ) = @_;
  croak 'usage CGP::CLI->List($listName, $command, $subscriber, @options)'
      unless defined $listName && defined $command && defined $subscriber;

  $this->send('LIST '.$listName.' '.$command.' '.join(' ',@options).' '.$subscriber);
  $this->_parseResponse();
}

sub ListSubscribers {
  my ( $this, $listName,$filter,$limit ) = @_;    
  croak 'usage CGP::CLI->ListSubscribers($listName [,$filter[,$limit]])'
      unless defined $listName;

  my $line = 'ListSubscribers '.$listName;
  $line .= ' FILTER '. ($filter eq '' ? '""' : $this->printWords($filter)) if($filter || $limit);
  $line .= " $limit" if($limit);
  
  $this->send($line );
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub GetSubscriberInfo {
  my ( $this, $listName,$address ) = @_;    
  croak 'usage CGP::CLI->GetSubscriberInfo($listName ,$subscriberAddress)'
      unless defined $listName && defined $address;
  $this->send('GetSubscriberInfo '.$listName.' NAME '.$address);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetPostingMode {
  my ($this, $listName, $address, $mode) = @_;
  croak 'usage CGP::CLI->SetPostingMode($listName,$subscriberAddress,$mode)'
      unless defined $listName && defined $address && defined $mode;
  $this->send('SetPostingMode '.$listName.' FOR '.$address.' '.$mode);
  $this->_parseResponse();
}


#############################################
#   Web Skins Administration 
 
sub ListDomainSkins {
  my ($this, $domainName) = @_;
  my $line = 'ListDomainSkins';
  $line .= ' '.$domainName if($domainName);
  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub CreateDomainSkin {
  my ( $this, $domain, $skin ) = @_;
  croak 'usage CGP::CLI->CreateDomainSkin($domainName,$skinName)'
      unless defined $domain && defined $skin;

  $this->send('CreateDomainSkin '.$domain.' SKIN '.$this->printWords($skin));
  $this->_parseResponse();
}

sub RenameDomainSkin {
  my ( $this, $domain, $skin, $newName ) = @_;
  croak 'usage CGP::CLI->RenameDomainSkin($domainName,$oldSkinName,$newSkinName)'
      unless defined $domain && defined $skin && defined $newName;

  $this->send('RenameDomainSkin '.$domain.' SKIN '.$this->printWords($skin).' INTO '.$this->printWords($newName));
  $this->_parseResponse();
}

sub DeleteDomainSkin {
  my ( $this, $domain, $skin ) = @_;
  croak 'usage CGP::CLI->DeleteDomainSkin($domainName,$skinName)'
      unless defined $domain && defined $skin;

  $this->send('DeleteDomainSkin '.$domain.' SKIN '.$this->printWords($skin));
  $this->_parseResponse();
}

sub ListDomainSkinFiles {
  my ( $this, $domain, $skin ) = @_;
  croak 'usage CGP::CLI->ListDomainSkinFiles($domainName,$skinName)'
      unless defined $domain && defined $skin;
  
  $this->send('ListDomainSkinFiles '.$domain.' SKIN '.$this->printWords($skin));
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub ReadDomainSkinFile {
  my ( $this, $domain, $skin, $fileName ) = @_;
  croak 'usage CGP::CLI->ReadDomainSkinFile($domainName,$skinName,$fileName)'
      unless defined $domain && defined $skin && defined $fileName;

  $this->send('ReadDomainSkinFile '.$domain.' SKIN '.$this->printWords($skin).' FILE '.$this->printWords($fileName));
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub StoreDomainSkinFile {
  my ( $this, $domain, $skin, $fileName,$base64data ) = @_;
  croak 'usage CGP::CLI->StoreDomainSkinFile($domainName,$skinName,$fileName,$base64data)'
      unless defined $domain && defined $skin && defined $fileName && defined $base64data;
  $this->send('StoreDomainSkinFile '.$domain.' SKIN '.$this->printWords($skin).' FILE '.$this->printWords($fileName).' DATA "'.$base64data.'"');
  $this->_parseResponse();
}

sub DeleteDomainSkinFile {
  my ( $this, $domain, $skin, $fileName ) = @_;
  croak 'usage CGP::CLI->DeleteDomainSkinFile($domainName,$skinName,$fileName)'
      unless defined $domain && defined $skin && defined $fileName;

  $this->send('StoreDomainSkinFile '.$domain.' SKIN '.$this->printWords($skin).' FILE '.$this->printWords($fileName).' DELETE');
  $this->_parseResponse();
}

#--
sub ListServerSkins {
  my ($this) = @_;
  $this->send('ListServerSkins');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub CreateServerSkin {
  my ( $this, $skin ) = @_;
  croak 'usage CGP::CLI->CreateServerSkin($skinName)'
      unless defined $skin;

  $this->send('CreateServerSkin '.$this->printWords($skin));
  $this->_parseResponse();
}

sub RenameServerSkin {
  my ( $this, $skin, $newName ) = @_;
  croak 'usage CGP::CLI->RenameServerSkin($oldSkinName,$newSkinName)'
      unless defined $skin && defined $newName;

  $this->send('RenameServerSkin '.$this->printWords($skin).' INTO '.$this->printWords($newName));
  $this->_parseResponse();
}

sub DeleteServerSkin {
  my ( $this, $skin ) = @_;
  croak 'usage CGP::CLI->DeleteServerSkin($skinName)'
      unless defined $skin;

  $this->send('DeleteServerSkin '.$this->printWords($skin));
  $this->_parseResponse();
}

sub ListServerSkinFiles {
  my ( $this, $skin ) = @_;
  croak 'usage CGP::CLI->ListServerSkinFiles($skinName)'
      unless defined $skin;

  $this->send('ListServerSkinFiles '.$this->printWords($skin));
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub ReadServerSkinFile {
  my ( $this, $skin, $fileName ) = @_;
  croak 'usage CGP::CLI->ReadServerSkinFile($skinName,$fileName)'
      unless defined $skin && defined $fileName;

  $this->send('ReadServerSkinFile '.$this->printWords($skin).' FILE '.$this->printWords($fileName));
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub StoreServerSkinFile {
  my ( $this, $skin, $fileName,$data ) = @_;
  croak 'usage CGP::CLI->StoreServerSkinFile($skinName,$fileName,$base64data)'
      unless defined $skin && defined $fileName && defined $data;

  $this->send('StoreServerSkinFile '.$this->printWords($skin).' FILE '.$this->printWords($fileName).' DATA "'.$data.'"');
  $this->_parseResponse();
}

sub DeleteServerSkinFile {
  my ( $this, $skin, $fileName ) = @_;
  croak 'usage CGP::CLI->DeleteServerSkinFile($skinName,$fileName)'
      unless defined $skin && defined $fileName;

  $this->send('StoreServerSkinFile '.$this->printWords($skin).' FILE '.$this->printWords($fileName).' DELETE');
  $this->_parseResponse();
}

#--
sub ListClusterSkins {
  my ($this) = @_;
  $this->send('ListClusterSkins');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub CreateClusterSkin {
  my ( $this, $skin ) = @_;
  croak 'usage CGP::CLI->CreateClusterSkin($skinName)'
      unless defined $skin;

  $this->send('CreateClusterSkin '.$this->printWords($skin));
  $this->_parseResponse();
}

sub RenameClusterSkin {
  my ( $this, $skin, $newName ) = @_;
  croak 'usage CGP::CLI->RenameClusterSkin($oldSkinName,$newSkinName)'
      unless defined $skin && defined $newName;

  $this->send('RenameClusterSkin '.$this->printWords($skin).' INTO '.$this->printWords($newName));
  $this->_parseResponse();
}

sub DeleteClusterSkin {
  my ( $this, $skin ) = @_;
  croak 'usage CGP::CLI->DeleteClusterSkin($skinName)'
      unless defined $skin;

  $this->send('DeleteClusterSkin '.$this->printWords($skin));
  $this->_parseResponse();
}

sub ListClusterSkinFiles {
  my ( $this, $skin ) = @_;
  croak 'usage CGP::CLI->ListClusterSkinFiles($skinName)'
      unless defined $skin;

  $this->send('ListClusterSkinFiles '.$this->printWords($skin));
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub ReadClusterSkinFile {
  my ( $this, $skin, $fileName ) = @_;
  croak 'usage CGP::CLI->ReadClusterSkinFile($skinName,$fileName)'
      unless defined $skin && defined $fileName;

  $this->send('ReadClusterSkinFile '.$this->printWords($skin).' FILE '.$this->printWords($fileName));
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub StoreClusterSkinFile {
  my ( $this, $skin, $fileName,$data ) = @_;
  croak 'usage CGP::CLI->StoreClusterSkinFile($skinName,$fileName,$base64data)'
      unless defined $skin && defined $fileName && defined $data;

  $this->send('StoreClusterSkinFile '.$this->printWords($skin).' FILE '.$this->printWords($fileName).' DATA "'.$data.'"');
  $this->_parseResponse();
}

sub DeleteClusterSkinFile {
  my ( $this, $skin, $fileName ) = @_;
  croak 'usage CGP::CLI->DeleteClusterSkinFile($skinName,$fileName)'
      unless defined $skin && defined $fileName;

  $this->send('StoreClusterSkinFile '.$this->printWords($skin).' FILE '.$this->printWords($fileName).' DELETE');
  $this->_parseResponse();
}

#############################################
#   Web Interface Tuning

sub ListWebUserInterface {
  my ($this, $domainName, $path) = @_;

  my $line = 'ListWebUserInterface';
  $line .= ' '.$domainName if($domainName);
  $line .= ' PATH '.$this->printWords($path) if($path);

  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub GetWebUserInterface {
  my ($this, $domainName, $path) = @_;
  croak 'usage CGP::CLI->GetWebUserInterface($domainName, $fileName)'
    unless defined $domainName && defined $path;

  my $line = 'GetWebUserInterface '.$domainName.' FILE '.$this->printWords($path);
  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub PutWebUserInterface {
  my ($this, $domainName, $path, $data) = @_;
  croak 'usage CGP::CLI->PutWebUserInterface($domainName, $fileName, $base64data)'
    unless defined $domainName && defined $path && defined $data;

  my $line = 'PutWebUserInterface '.$domainName;
  $line .= ' FILE '.$this->printWords($path).' DATA "'.$data.'"';
  $this->send($line);
  $this->_parseResponse();
}

sub DeleteWebUserInterface {
  my ($this, $domainName, $path) = @_;
  croak 'usage CGP::CLI->DeleteWebUserInterface($domainName, $fileName)'
    unless defined $domainName && defined $path;

  my $line = 'DeleteWebUserInterface ';
  $line .= ' '.$domainName if($domainName);
  $line .= ' FILE '.$this->printWords($path) if($path);

  $this->send($line);
  $this->_parseResponse();
}

sub ClearWebUserCache {
  my ($this, $domainName) = @_;

  my $line = 'ClearWebUserCache';
  $line .= ' '.$domainName if($domainName);

  $this->send($line);
  $this->_parseResponse();
}

#############################################
#   Web Interface Integration

sub CreateWebUserSession {
  my ($this, $accountName, $ipAddress) = @_;
  croak 'usage CGP::CLI->CreateWebUserSession($accountName, $IP_Address)'
    unless defined $accountName && defined $ipAddress;

  $this->send('CreateWebUserSession '.$accountName.' ADDRESS '.$ipAddress);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub GetWebUserSession {
  my ($this, $sessionID,$domain) = @_;
  croak 'usage CGP::CLI->GetWebUserSession($sessionID [,$domain])' unless defined $sessionID;

  my $line='GetWebUserSession '.$sessionID;
  $line .= ' DOMAIN '.$domain if($domain);

  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub KillWebUserSession {
  my ($this, $sessionID,$domain) = @_;
  croak 'usage CGP::CLI->KillWebUserSession($sessionID [,$domain])' unless defined $sessionID;
  my $line='KillWebUserSession '.$sessionID;
  $line .= ' DOMAIN '.$domain if($domain);

  $this->send($line);
  $this->_parseResponse();
}


#############################################
#  Server Settings

sub GetModule {
  my ( $this, $moduleName ) = @_;
  $this->send('GetModule '.$moduleName);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub UpdateModule {
  my ( $this, $moduleName, $newSettings ) = @_;
  croak 'usage CGP::CLI->UpdateModule($moduleName, \%newSettings)'
    unless defined $moduleName && defined $newSettings;
  $this->send ('UpdateModule '.$moduleName.' '.$this->printWords($newSettings) );
  $this->_parseResponse();
}

sub SetModule {
  my ( $this, $moduleName, $newSettings ) = @_;
  croak 'usage CGP::CLI->SetModule($moduleName, \%newSettings)'
    unless defined $moduleName && defined $newSettings;
  $this->send ('SetModule '.$moduleName.' '.$this->printWords($newSettings) );
  $this->_parseResponse();
}

sub GetBlacklistedIPs {
  my ( $this ) = @_;
  $this->send('GetBlacklistedIPs');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub GetClientIPs {
  my ( $this ) = @_;
  $this->send('GetClientIPs');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub GetWhiteHoleIPs {
  my ( $this ) = @_;
  $this->send('GetWhiteHoleIPs');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub GetProtection {
  my ( $this ) = @_;
  $this->send('GetProtection');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub GetBanned {
  my ( $this ) = @_;
  $this->send('GetBanned');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetBlacklistedIPs {
  my ( $this, $addresses ) = @_;
  croak 'usage CGP::CLI->SetBlacklistedIPs("11.22.33.44\e55.66.77.88")'
    unless defined $addresses;
  $this->send ('SetBlacklistedIPs '.$this->printWords($addresses));
  $this->_parseResponse();
}

sub SetClientIPs {
  my ( $this, $addresses ) = @_;
  croak 'usage CGP::CLI->SetClientIPs("11.22.33.44\e55.66.77.88")'
    unless defined $addresses;
  $this->send ('SetClientIPs '.$this->printWords($addresses));
  $this->_parseResponse();
}

sub SetWhiteHoleIPs {
  my ( $this, $addresses ) = @_;
  croak 'usage CGP::CLI->SetWhiteHoleIPs("11.22.33.44\e55.66.77.88")'
    unless defined $addresses;
  $this->send ('SetWhiteHoleIPs '.$this->printWords($addresses));
  $this->_parseResponse();
}

sub SetProtection {
  my ( $this, $settings ) = @_;
  croak 'usage CGP::CLI->SetProtection(\%settings)'
    unless defined $settings;
  $this->send ('SetProtection '.$this->printWords($settings));
  $this->_parseResponse();
}

sub SetBanned {
  my ( $this, $settings ) = @_;
  croak 'usage CGP::CLI->SetBanned(\%settings)'
    unless defined $settings;
  $this->send ('SetBanned '.$this->printWords($settings));
  $this->_parseResponse();
}

sub GetClusterBlacklistedIPs {
  my ( $this ) = @_;
  $this->send('GetClusterBlacklistedIPs');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub GetClusterClientIPs {
  my ( $this ) = @_;
  $this->send('GetClusterClientIPs');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub GetClusterWhiteHoleIPs {
  my ( $this ) = @_;
  $this->send('GetClusterWhiteHoleIPs');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub GetClusterProtection {
  my ( $this ) = @_;
  $this->send('GetClusterProtection');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}
sub GetClusterBanned {
  my ( $this ) = @_;
  $this->send('GetClusterBanned');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetClusterBlacklistedIPs {
  my ( $this, $addresses ) = @_;
  croak 'usage CGP::CLI->SetClusterBlacklistedIPs("11.22.33.44\e55.66.77.88")'
    unless defined $addresses;
  $this->send ('SetClusterBlacklistedIPs '.$this->printWords($addresses));
  $this->_parseResponse();
}

sub SetClusterClientIPs {
  my ( $this, $addresses ) = @_;
  croak 'usage CGP::CLI->SetClusterClientIPs("11.22.33.44\e55.66.77.88")'
    unless defined $addresses;
  $this->send ('SetClusterClientIPs '.$this->printWords($addresses));
  $this->_parseResponse();
}

sub SetClusterWhiteHoleIPs {
  my ( $this, $addresses ) = @_;
  croak 'usage CGP::CLI->SetClusterWhiteHoleIPs("11.22.33.44\e55.66.77.88")'
    unless defined $addresses;
  $this->send ('SetClusterWhiteHoleIPs '.$this->printWords($addresses));
  $this->_parseResponse();
}

sub SetClusterProtection {
  my ( $this, $settings ) = @_;
  croak 'usage CGP::CLI->SetClusterProtection(\%settings)'
    unless defined $settings;
  $this->send ('SetClusterProtection '.$this->printWords($settings));
  $this->_parseResponse();
}

sub GetServerRules {
  my $this = shift;
  $this->send('GetServerRules');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetServerRules {
  my ($this, $rules) = @_;
  croak 'usage CGP::CLI->SetServerRules(\@rules)'
    unless defined $rules;
  $this->send('SetServerRules '.$this->printWords($rules));
  $this->_parseResponse();
}

sub GetClusterRules {
  my $this = shift;
  $this->send('GetClusterRules');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetClusterRules {
  my ($this, $rules) = @_;
  croak 'usage CGP::CLI->SetClusterRules(\@rules)'
    unless defined $rules;
  $this->send('SetClusterRules '.$this->printWords($rules));
  $this->_parseResponse();
}

sub RefreshOSData {
  my ($this) = @_;
  $this->send('RefreshOSData');
  $this->_parseResponse();
}

sub GetRouterTable {
  my $this = shift;
  $this->send('GetRouterTable');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetRouterTable {
  my ($this, $table) = @_;
  croak 'usage CGP::CLI->GetRouterTable("<addr1>=addr1\@domain.com\\e<addr2>=addr2\@domain.com\\e")'
    unless defined $table;
  $this->send('SetRouterTable '.$this->printWords($table));
  $this->_parseResponse();
}

sub GetRouterSettings {
  my $this = shift;
  $this->send('GetRouterSettings');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetRouterSettings {
  my ($this, $settings) = @_;
  croak 'usage CGP::CLI->SetRouterSettings(\@settings)'
    unless defined $settings;
  $this->send('SetRouterSettings '.$this->printWords($settings));
  $this->_parseResponse();
}


sub GetClusterRouterTable {
  my $this = shift;
  $this->send('GetClusterRouterTable');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub SetClusterRouterTable {
  my ($this, $table) = @_;
  croak 'usage CGP::CLI->SetClusterRouterTable("<addr1>=addr1\@domain.com\\e<addr2>=addr2\@domain.com\\e")'
    unless defined $table;
  $this->send('SetClusterRouterTable '.$this->printWords($table));
  $this->_parseResponse();
}


sub GetServerIntercept {
  my ( $this ) = @_;
  $this->send('GetServerIntercept');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}
sub SetServerIntercept {
  my ( $this, $settings ) = @_;
  croak 'usage CGP::CLI->SetServerIntercept(\%settings)'
    unless defined $settings;
  $this->send ('SetServerIntercept '.$this->printWords($settings));
  $this->_parseResponse();
}

sub GetClusterIntercept {
  my ( $this ) = @_;
  $this->send('GetClusterIntercept');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}
sub SetClusterIntercept {
  my ( $this, $settings ) = @_;
  croak 'usage CGP::CLI->SetClusterIntercept(\%settings)'
    unless defined $settings;
  $this->send ('SetClusterIntercept '.$this->printWords($settings));
  $this->_parseResponse();
}


sub Route {
  my ($this, $address, $mail) = @_;
  croak 'usage CGP::CLI->Route(address[,"mail"])'
    unless defined $address;
  my $line='Route '.$address;
  $line .= ' mail' if($mail);
  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

#############################################
#  Monitoring commands

sub GetSNMPElement {
  my ($this, $element) = @_;
  $this->send('GetSNMPElement '.$element);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub Shutdown {
  my $this = shift;
  $this->send('SHUTDOWN');
  $this->_parseResponse();
}

#############################################
#  Statistics commands

sub GetAccountStat {
  my ($this, $account, $key) = @_;
  croak 'usage CGP::CLI->GetAccountStat($account[,$key])'
    unless defined $account;
  my $line = 'GetAccountStat '.$account;
  $line .= ' Key '.$key if $key;
  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub ResetAccountStat {
  my ($this, $account, $key) = @_;
  croak 'usage CGP::CLI->ResetAccountStat($account[,$key])'
    unless defined $account;
  my $line = 'ResetAccountStat '.$account;
  $line .= ' Key '.$key if $key;
  $this->send($line);
  $this->_parseResponse();
}

sub GetDomainStat {
  my ($this, $domain, $key) = @_;
  croak 'usage CGP::CLI->GetDomainStat($domain[,$key])'
    unless defined $domain;
  my $line = 'GetDomainStat '.$domain;
  $line .= ' Key '.$key if $key;
  $this->send($line);
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub ResetDomainStat {
  my ($this, $domain, $key) = @_;
  croak 'usage CGP::CLI->ResetDomainStat($domain[,$key])'
    unless defined $domain;
  my $line = 'ResetDomainStat '.$domain;
  $line .= ' Key '.$key if $key;
  $this->send($line);
  $this->_parseResponse();
}

#############################################
#  Miscellaneous commands

sub WriteLog {
  my ($this, $level, $msg) = @_;
  croak 'usage CGP::CLI->WriteLog($level,$message)'
    unless defined $level && defined $msg;
  $this->send('WriteLog '.$level.' '.$this->printWords($msg));
  $this->_parseResponse();
}
sub ReleaseSMTPQueue {
  my ($this, $queue) = @_;
  croak 'usage CGP::CLI->ReleaseSMTPQueue($queueName)'
    unless defined $queue;
  $this->send('ReleaseSMTPQueue '.$queue);
  $this->_parseResponse();
}
sub RejectQueueMessage {
  my ($this, $msg, $text) = @_;
  croak 'usage CGP::CLI->RejectQueueMessage($msgID [,$errorText])'
    unless defined $msg;
  my $line = 'RejectQueueMessage '.$msg;
  $line .= $this->printWords($text) if $text;
  $this->send($line);
  $this->_parseResponse();
}

sub GetCurrentController {
  my ($this) = @_;
  $this->send('GetCurrentController');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}
sub GetTempClientIPs  {
  my ($this) = @_;
  $this->send('GetTempClientIPs');
  return undef unless $this->_parseResponse();
  $this->parseWords($this->getWords);
}

sub RemoveAccountSubset  {
  my ($this, $account, $subset) = @_;
  croak 'usage CGP::CLI->RemoveAccountSubset($account,$subset)'
    unless defined $account && defined $subset;       
  $this->send('RemoveAccountSubset '.$account.' SUBSET '.$this->printWords($subset));
  return undef unless $this->_parseResponse();
}


#########################################################################
#########################################################################
##  Internal routines

sub _setStrangeError
{
    my ($this, $line, $code) = @_;
    if ($code)
    {
        ${*$this}{'errCode'} = $code;
    }
    else
    {
        ${*$this}{'errCode'} = $CGP::CLI_CODE_STRANGE;
    }
    ${*$this}{'errMsg'} = $line;
    return $CGP::FALSE;
}

sub _parseResponse
{
  my $this = shift;
  my $responseLine = <$this>;

  print STDERR "CGP::CLI->_parseResponse::responseLine = $responseLine\n\n"
      if ${*$this}{'debug'};

  $responseLine =~ /^(\d+)\s(.*)$/;
  return $this->_setStrangeError($responseLine) unless ($1);
  ${*$this}{'errCode'} = $1;
  if($1 == $CGP::CLI_CODE_OK_INLINE) {
    ${*$this}{'inlineResponse'} = $2;	
    ${*$this}{'errMsg'} = 'OK';
  } else {
    ${*$this}{'errMsg'} = $2;
    chomp(${*$this}{'errMsg'});
    ${*$this}{'errMsg'} =~ s/\r$//;
  }
  $this->isSuccess;
}

sub convertOutput {
  my $data = $_[0];
  my $translate = $_[1];
  if(!defined($data)) {
    return '""';
  } elsif(ref($data) eq 'HASH') {
    my $outp='{';
    #$outp.="\n";
    foreach (sort keys %$data) {
      my $value=@$data{$_};
      $outp .= convertOutput($_,$translate).'='.convertOutput($value,$translate).';';
      #$outp.="\n";
    }
    $outp.= '}';
    #$outp.="\n";
    return $outp;
  } elsif(ref($data) eq 'ARRAY') {
    my $outp='(';
    my $first=1;
    foreach (@$data) {
      if(!$first) { $outp.=','; } else { $first=0; }
      $outp.=convertOutput($_,$translate);
    }
    $outp.= ')';
    return $outp;
  } else {
    if($data =~ /[\W_]/ || $data eq '') {
      if($translate) {
        $data =~ s/\\((?![enr\d]))/\\\\$1/g;
        $data =~ s/\"/\\\"/g;
      }
      $data =~ s/([\x00-\x1F\x7F])/'\\'.('0'x(3-length(ord($1)))).ord($1)/ge;

      return '"' . $data . '"';
    } else {
      return $data;
    }
  }
}

sub printWords {
  my ($this,$data)= @_;
  return convertOutput($data,${*$this}{'translateStrings'});
}

sub strip
{
    my $line = shift;
    $line =~ s/^\s+//;
    $line =~ s/\s+$//;
    return $line;
}

sub getWords {
  my $this = shift;
  if(${*$this}{'errCode'} == $CGP::CLI_CODE_OK_INLINE) {
	return ${*$this}{'inlineResponse'};
  }
  my ($bag, $line) = ('', '');
  my $firstLine = $CGP::TRUE;
  my $lastLine = '';
  while ($CGP::TRUE) {
    $line = <$this>;
    chomp $line;
    $line = strip($line);
    if($firstLine) {
      $line =~ /^(.)/;
      if ($1) {
        $lastLine = '\)' if $1 eq '(';
        $lastLine = '\}' if $1 eq '{';
        $lastLine = $lastLine . '$';
        $firstLine = $CGP::FALSE;
      }
    }
    $bag .= $line;
    last if $line =~ /$lastLine/;
  }
  return $bag;
}


sub send {
  my ($this, $command) = @_;
  ${*$this}{currentCGateCommand} = $command;
  print STDERR ref($this) . "->send($command)\n\n"
    if ${*$this}{'debug'};

  print $this $command.$CGP::CLI_CRLF;
}


my $len;
my $span;
my $data;
my $translate;

sub skipSpaces {
  while($span < $len && substr($data,$span,1) =~ /\s/) { ++$span; }
}

sub readWord {
  my $isQuoted=0;
  my $isBlock=0;
  my $result="";

  skipSpaces();
  if(substr($data,$span,1) eq '"') {
    $isQuoted=1; ++$span;
  } elsif(substr($data,$span,1) eq '[') {
    $isBlock=1;
  }
  while($span < $len) {
    my $ch=substr($data,$span,1);

    if($isQuoted) {
      if($ch eq '\\') {
        if(substr($data,$span+1,3) =~ /^(?:\"|\\|\d\d\d)/) { 
          $ch=substr($data,++$span,3);
          if($ch =~ /\d\d\d/) {
            $span+=2;
            $ch=chr($ch);
          } else {
            $ch=substr($ch,0,1);
            $ch='\\'.$ch unless($translate); 
          }
        }
      } elsif($ch eq '"') {
        ++$span;
        last;
      }
    } elsif($isBlock) {
      if($ch eq ']') {
        $result .= $ch;
        ++$span;
        last;
      }
    } elsif($ch =~ /[-a-zA-Z0-9\x80-\xff_\.\@\!\#\%]/) {    
    } else {
      last;
    }
    $result .= $ch;
    ++$span;
  }
  return $result;
}


sub readKey() {
  return readWord();
}


sub readValue() {
  skipSpaces();
  my $ch=substr($data,$span,1);
  if($ch eq '{') {
    ++$span;
    return readDictionary();
  } elsif($ch eq '(') {
    ++$span;
    return readArray();
  } else {
    return readWord();
  }
}

sub readArray() {
  my $result=[];
  while($span<$len) {
    skipSpaces();
    if(substr($data,$span,1) eq ')') {
      ++$span;
      last;
    } else {
      my $theValue=readValue();
      skipSpaces();
      push(@$result,$theValue);
      if(substr($data,$span,1) eq ',') {
        ++$span;
      } elsif(substr($data,$span,1) eq ')') {
      } else { 
        croak "CGPro output format error:",substr($data,$span,10);
      }     
    }
  }
  return $result;
}

sub readDictionary {
  my $result={};
  while($span < $len) {
    skipSpaces();
    if(substr($data,$span,1) eq '}') {
      ++$span;
      last;
    } else {
      my $theKey=readKey();
      skipSpaces();
      if(substr($data,$span,1) ne '=') { croak "CGPro output format error:",substr($data,$span,10); }
      ++$span;
      @$result{$theKey}=readValue();
      skipSpaces();
      if(substr($data,$span,1) ne ';') { croak "CGPro output format error:",substr($data,$span,10); }
      ++$span;
    }
  }
  return $result;
}

sub parseWords {
  my $this = shift;
  $data = shift;
  $span=0;
  $len=length($data);
  $translate = ${*$this}{'translateStrings'};
  return readValue();
}

1;
 
