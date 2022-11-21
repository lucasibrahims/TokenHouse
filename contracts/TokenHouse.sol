// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

contract TokenHouse is ERC721Enumerable, Ownable {
  using Strings for uint256;
  
   struct Imovel {
      string id; 
      string endereco;
      string linkVideo;
      string quartos;
      string banheiros;
      string area;
         }
  
  mapping (uint256 => Imovel) public imoveis;
  
  constructor() ERC721("Token House", "THS") {}

  function mint(
      string memory _endereco, 
      string memory _linkVideo,
      string memory _quartos,
      string memory _banheiros,
      string memory _area) public payable {

        uint256 supply = totalSupply();
        Imovel memory novoImovel = Imovel(
          string(abi.encodePacked('Token House #', uint256(supply + 1).toString())),
          _endereco,
          _linkVideo,
          _quartos,
          _banheiros,
          _area
        );
    require(supply + 1 <= 1000);
    
    if (msg.sender != owner()) {
      require(msg.value >= 0.005 ether);
    }
    
    imoveis[supply + 1] = novoImovel;
    _safeMint(msg.sender, supply + 1);
  }

  function randomNum(uint256 _mod, uint256 _seed, uint _salt) public view returns(uint256) {
      uint256 num = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
      return num;
  }
  
  function buildImage(uint256 _tokenId) public view returns(string memory) {
      Imovel memory currentImovel = imoveis[_tokenId];
      return Base64.encode(bytes(
          abi.encodePacked(
            '<?xml version="1.0" encoding="utf-8"?>',
            '<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">',
            '<text style="fill: rgb(51, 51, 51); font-family: Chilanka; font-size: 16.1px; letter-spacing: 1.1px; text-anchor: middle; white-space: pre;" transform="matrix(1.293121, 0, 0, 1.355514, 203.696869, -25.641428)">',
            '<tspan x="33.295" y="185.993">',currentImovel.endereco,'</tspan></text>',
            '</svg>'   
          )
      ));
  }

  
  function buildMetadata(uint256 _tokenId) public view returns(string memory) {
      Imovel memory currentImovel = imoveis[_tokenId];
      return string(abi.encodePacked(
              'data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
                          '{"name":"', 
                          currentImovel.id,
                          '", "description":', 
                          '"Token House by 2ndMarket, endereco: ',currentImovel.endereco,',"',
                          ',"image": "', 
                          'data:image/svg+xml;base64,', 
                          buildImage(_tokenId),
                          '","youtube_url":',
                          '"',currentImovel.linkVideo,'"',
                          ',"attributes": [',
                            '{',
                            '  "trait_type": "Quartos",',
                            '  "value": "',currentImovel.quartos,'"',
                            '},',
                            '{',
                            '  "trait_type": "Banheiros",',
                            ' "value": "',currentImovel.banheiros,'"',
                            '},',
                            '{',
                            '  "trait_type": "Area Total Construida",',
                            ' "value": "',currentImovel.area,'m2"',
                            '}',
                            
                          ']',
                          '}')))));
  }

  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
      require(_exists(_tokenId),"ERC721Metadata: URI query for nonexistent token");
      return buildMetadata(_tokenId);
  }

  function withdraw() public payable onlyOwner {
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }
}