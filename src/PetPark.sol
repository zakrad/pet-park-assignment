//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PetPark is Ownable {
    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female
    }

    struct BorrowerInfo {
        AnimalType borrowedType;
        Gender gender;
        uint8 age;
    }

    modifier initialCheck(uint8 age, Gender gender) {
        require(age != 0, "Invalid Age");

        BorrowerInfo storage userInfo = info[msg.sender];

        if (userInfo.age != 0) {
            require(userInfo.age == age, "Invalid Age");
            require(userInfo.gender == gender, "Invalid Gender");
        } else {
            userInfo.age = age;
            userInfo.gender = gender;
        }
        _;
    }

    mapping(address => bool) public hasBorrowed;
    mapping(address => BorrowerInfo) public info;
    mapping(AnimalType => uint256) public animalCounts;

    event Added(AnimalType _type, uint256 _count);
    event Borrowed(AnimalType _type);
    event Returned(AnimalType _type);

    function add(AnimalType _type, uint256 _count) external onlyOwner {
        require(_type != AnimalType.None, "Invalid animal");
        animalCounts[_type] += _count;
        emit Added(_type, _count);
    }

    function borrow(uint8 _age, Gender _gender, AnimalType _type) external initialCheck(_age, _gender) {
        require(_type != AnimalType.None, "Invalid animal type");
        require(animalCounts[_type] != 0, "Selected animal not available");
        require(hasBorrowed[msg.sender] == false, "Already adopted a pet");

        BorrowerInfo storage userInfo = info[msg.sender];

        if (
            _gender == Gender.Male
                && (_type == AnimalType.Cat || _type == AnimalType.Rabbit || _type == AnimalType.Parrot)
        ) {
            revert("Invalid animal for men");
        }
        if (_gender == Gender.Female && _age < 40 && _type == AnimalType.Cat) {
            revert("Invalid animal for women under 40");
        }
        animalCounts[_type] -= 1;
        userInfo.borrowedType = _type;
        hasBorrowed[msg.sender] = true;

        emit Borrowed(_type);
    }

    function giveBackAnimal() external {
        require(hasBorrowed[msg.sender] == true, "No borrowed pets");

        hasBorrowed[msg.sender] == false;
        AnimalType borrowedType = info[msg.sender].borrowedType;

        animalCounts[borrowedType] += 1;
        info[msg.sender].borrowedType = AnimalType.None;
        emit Returned(borrowedType);
    }
}
