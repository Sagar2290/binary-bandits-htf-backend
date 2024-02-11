// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EduChain is ERC721, Ownable {
    uint256 private _currentCourseId;
    mapping(uint256 => bool) private _exists;

    struct Course {
        string title;
        string description;
        uint256 price;
        address owner;
    }

    mapping(uint256 => Course) public courses;

    event CourseCreated(uint256 indexed courseId, string title, string description, uint256 price, address owner);
    event CoursePurchased(uint256 indexed courseId, address buyer);
    event CourseResold(uint256 indexed courseId, address seller, address buyer);

    constructor() ERC721("EduChain", "EDU") Ownable(msg.sender) {}

    function createCourse(string memory _title, string memory _description, uint256 _price) external {
        _currentCourseId++;
        uint256 newCourseId = _currentCourseId;
        _mint(msg.sender, newCourseId);
        courses[newCourseId] = Course(_title, _description, _price, msg.sender);
        _exists[newCourseId] = true; // Mark the course as existing
        emit CourseCreated(newCourseId, _title, _description, _price, msg.sender);
    }

    function purchaseCourse(uint256 _courseId) external payable {
        require(_exists[_courseId], "Course does not exist"); // Check if the course exists
        Course memory course = courses[_courseId];
        require(msg.value >= course.price, "Insufficient funds");
        address previousOwner = course.owner;
        _transfer(previousOwner, msg.sender, _courseId);
        payable(previousOwner).transfer(msg.value);
        emit CoursePurchased(_courseId, msg.sender);
    }

    function resellCourse(uint256 _courseId, uint256 _price) external {
        require(_exists[_courseId], "Course does not exist"); // Check if the course exists
        require(ownerOf(_courseId) == msg.sender, "You are not the owner of this course");
        courses[_courseId].price = _price;
    }

    function transferCourseOwnership(uint256 _courseId, address _newOwner) external {
        require(_exists[_courseId], "Course does not exist"); // Check if the course exists
        require(ownerOf(_courseId) == msg.sender, "You are not the owner of this course");
        _transfer(msg.sender, _newOwner, _courseId);
        courses[_courseId].owner = _newOwner;
    }
}
