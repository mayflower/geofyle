jest.mock('@aws-sdk/client-dynamodb');
jest.mock('@aws-sdk/lib-dynamodb');

const { handler } = require('../../src/handlers/getNearbyFiles');
const dynamodb = require('../../src/utils/dynamodb');
const geo = require('../../src/utils/geo');

// Mock dependencies
jest.mock('../../src/utils/dynamodb');
jest.mock('../../src/utils/geo');

describe('getNearbyFiles handler', () => {
  beforeEach(() => {
    // Reset mocks before each test
    jest.clearAllMocks();
    
    // Mock environment variables
    process.env.FILES_TABLE = 'test-files-table';
    process.env.DEFAULT_RADIUS_METERS = '100';
  });
  
  test('should return nearby files successfully', async () => {
    // Mock input event
    const event = {
      queryStringParameters: {
        latitude: '40.7128',
        longitude: '-74.0060',
        radius: '200'
      }
    };
    
    // Mock geohash function
    geo.getNearbyGeohashes.mockReturnValue(['geohash1', 'geohash2']);
    geo.isWithinRange.mockReturnValue(true);
    
    // Set current time to ensure files aren't expired in test
    const now = Math.floor(Date.now() / 1000);
    
    // Mock DynamoDB query results
    const mockFiles = [
      {
        id: 'file1',
        name: 'Test File 1',
        description: 'Test Description 1',
        size: 1024,
        mimeType: 'image/jpeg',
        location: { latitude: 40.7130, longitude: -74.0065 },
        uploadTime: '2023-01-01T00:00:00Z',
        expirationTime: '2023-02-01T00:00:00Z',
        downloadCount: 5,
        geohash: 'geohash1',
        ttl: now + 86400 // Not expired (1 day in the future)
      },
      {
        id: 'file2',
        name: 'Test File 2',
        description: 'Test Description 2',
        size: 2048,
        mimeType: 'application/pdf',
        location: { latitude: 40.7135, longitude: -74.0070 },
        uploadTime: '2023-01-02T00:00:00Z',
        expirationTime: '2023-02-02T00:00:00Z',
        downloadCount: 10,
        geohash: 'geohash2',
        ttl: now + 86400 // Not expired (1 day in the future)
      }
    ];
    
    // Mock resolved promises for DynamoDB
    dynamodb.queryByIndex.mockImplementation((table, index, key, value) => {
      if (value === 'geohash1') return Promise.resolve([mockFiles[0]]);
      if (value === 'geohash2') return Promise.resolve([mockFiles[1]]);
      return Promise.resolve([]);
    });
    
    // Execute handler
    const response = await handler(event);
    
    // Verify response
    expect(response.statusCode).toBe(200);
    
    const body = JSON.parse(response.body);
    expect(body).toHaveLength(2);
    expect(body[0].id).toBe('file1');
    expect(body[1].id).toBe('file2');
    
    // Verify function calls
    expect(geo.getNearbyGeohashes).toHaveBeenCalledWith(40.7128, -74.0060, 200);
    expect(dynamodb.queryByIndex).toHaveBeenCalledTimes(2);
    expect(geo.isWithinRange).toHaveBeenCalledTimes(2);
  });
  
  test('should return 400 with invalid coordinates', async () => {
    // Mock input event with invalid latitude
    const event = {
      queryStringParameters: {
        latitude: '100', // Invalid latitude (> 90)
        longitude: '-74.0060'
      }
    };
    
    // Execute handler
    const response = await handler(event);
    
    // Verify response
    expect(response.statusCode).toBe(400);
    
    const body = JSON.parse(response.body);
    expect(body.code).toBe('INVALID_COORDINATES');
  });
  
  test('should return empty array when no files found', async () => {
    // Mock input event
    const event = {
      queryStringParameters: {
        latitude: '40.7128',
        longitude: '-74.0060'
      }
    };
    
    // Mock geohash function with no matching files
    geo.getNearbyGeohashes.mockReturnValue(['geohash1']);
    geo.isWithinRange.mockReturnValue(true);
    
    // Mock empty DynamoDB results
    dynamodb.queryByIndex.mockResolvedValue([]);
    
    // Execute handler
    const response = await handler(event);
    
    // Verify response
    expect(response.statusCode).toBe(200);
    
    const body = JSON.parse(response.body);
    expect(body).toHaveLength(0);
  });
  
  test('should filter out expired files', async () => {
    // Mock input event
    const event = {
      queryStringParameters: {
        latitude: '40.7128',
        longitude: '-74.0060'
      }
    };
    
    // Set current time for testing expiration
    const now = Math.floor(Date.now() / 1000);
    
    // Mock geohash function
    geo.getNearbyGeohashes.mockReturnValue(['geohash1']);
    geo.isWithinRange.mockReturnValue(true);
    
    // Mock files with one expired
    const mockFiles = [
      {
        id: 'file1',
        name: 'Expired File',
        description: 'This file is expired',
        size: 1024,
        mimeType: 'image/jpeg',
        location: { latitude: 40.7130, longitude: -74.0065 },
        uploadTime: '2023-01-01T00:00:00Z',
        expirationTime: '2023-01-02T00:00:00Z',
        downloadCount: 5,
        geohash: 'geohash1',
        ttl: now - 1000 // Expired
      },
      {
        id: 'file2',
        name: 'Valid File',
        description: 'This file is still valid',
        size: 2048,
        mimeType: 'application/pdf',
        location: { latitude: 40.7135, longitude: -74.0070 },
        uploadTime: '2023-01-02T00:00:00Z',
        expirationTime: '2023-02-02T00:00:00Z',
        downloadCount: 10,
        geohash: 'geohash1',
        ttl: now + 86400 // Not expired
      }
    ];
    
    dynamodb.queryByIndex.mockResolvedValue(mockFiles);
    
    // Execute handler
    const response = await handler(event);
    
    // Verify response
    expect(response.statusCode).toBe(200);
    
    const body = JSON.parse(response.body);
    expect(body).toHaveLength(1);
    expect(body[0].id).toBe('file2');
  });
});